#!/usr/bin/env bash
set -euo pipefail

OLD_IMAGE="${1:?Usage: $0 <old-window.png> <new-window.png> [diff-output.png]}"
NEW_IMAGE="${2:?Usage: $0 <old-window.png> <new-window.png> [diff-output.png]}"
DIFF_IMAGE="${3:-${DIFF_IMAGE:-}}"
MAX_AVG_DELTA="${MAX_AVG_DELTA:-8.0}"
MAX_BAD_PIXEL_RATIO="${MAX_BAD_PIXEL_RATIO:-0.04}"
BAD_PIXEL_THRESHOLD="${BAD_PIXEL_THRESHOLD:-32}"

/usr/bin/swift - "${OLD_IMAGE}" "${NEW_IMAGE}" "${MAX_AVG_DELTA}" "${MAX_BAD_PIXEL_RATIO}" "${BAD_PIXEL_THRESHOLD}" "${DIFF_IMAGE}" <<'SWIFT'
import CoreGraphics
import Foundation
import ImageIO

let oldPath = CommandLine.arguments[1]
let newPath = CommandLine.arguments[2]
let maxAverageDelta = Double(CommandLine.arguments[3]) ?? 8.0
let maxBadPixelRatio = Double(CommandLine.arguments[4]) ?? 0.04
let badPixelThreshold = Int(CommandLine.arguments[5]) ?? 32
let diffPath = CommandLine.arguments.count > 6 ? CommandLine.arguments[6] : ""

struct Region {
    let name: String
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}

struct Metrics {
    let pixels: Int
    let averageDelta: Double
    let maxDelta: Int
    let badPixels: Int

    var badPixelRatio: Double {
        pixels == 0 ? 0.0 : Double(badPixels) / Double(pixels)
    }
}

func loadPixels(_ path: String) throws -> (width: Int, height: Int, pixels: [UInt8]) {
    let url = URL(fileURLWithPath: path)
    guard
        let source = CGImageSourceCreateWithURL(url as CFURL, nil),
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        throw NSError(domain: "ScreenshotParity", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to read image: \(path)"])
    }

    let width = image.width
    let height = image.height
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(domain: "ScreenshotParity", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to allocate bitmap context"])
    }
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    return (width, height, pixels)
}

func clampRegion(name: String, x: Double, y: Double, width: Double, height: Double, imageWidth: Int, imageHeight: Int) -> Region {
    let clampedX = max(0, min(imageWidth - 1, Int((x * Double(imageWidth)).rounded())))
    let clampedY = max(0, min(imageHeight - 1, Int((y * Double(imageHeight)).rounded())))
    let clampedRight = max(clampedX + 1, min(imageWidth, Int(((x + width) * Double(imageWidth)).rounded())))
    let clampedBottom = max(clampedY + 1, min(imageHeight, Int(((y + height) * Double(imageHeight)).rounded())))
    return Region(name: name, x: clampedX, y: clampedY, width: clampedRight - clampedX, height: clampedBottom - clampedY)
}

func metrics(old: (width: Int, height: Int, pixels: [UInt8]), new: (width: Int, height: Int, pixels: [UInt8]), region: Region, badPixelThreshold: Int) -> Metrics {
    var totalDelta = 0
    var maxDelta = 0
    var badPixels = 0

    for row in region.y..<(region.y + region.height) {
        for column in region.x..<(region.x + region.width) {
            let oldIndex = (row * old.width + column) * 4
            let newIndex = (row * new.width + column) * 4
            let dr = abs(Int(old.pixels[oldIndex]) - Int(new.pixels[newIndex]))
            let dg = abs(Int(old.pixels[oldIndex + 1]) - Int(new.pixels[newIndex + 1]))
            let db = abs(Int(old.pixels[oldIndex + 2]) - Int(new.pixels[newIndex + 2]))
            let pixelDelta = max(dr, dg, db)
            totalDelta += dr + dg + db
            maxDelta = max(maxDelta, pixelDelta)
            if pixelDelta > badPixelThreshold {
                badPixels += 1
            }
        }
    }

    let pixelCount = region.width * region.height
    let averageDelta = pixelCount == 0 ? 0.0 : Double(totalDelta) / Double(pixelCount * 3)
    return Metrics(pixels: pixelCount, averageDelta: averageDelta, maxDelta: maxDelta, badPixels: badPixels)
}

func writeDiffImage(old: (width: Int, height: Int, pixels: [UInt8]), new: (width: Int, height: Int, pixels: [UInt8]), width: Int, height: Int, path: String, badPixelThreshold: Int) throws {
    guard !path.isEmpty else { return }

    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
    for row in 0..<height {
        for column in 0..<width {
            let diffIndex = (row * width + column) * 4
            let oldIndex = (row * old.width + column) * 4
            let newIndex = (row * new.width + column) * 4
            let dr = abs(Int(old.pixels[oldIndex]) - Int(new.pixels[newIndex]))
            let dg = abs(Int(old.pixels[oldIndex + 1]) - Int(new.pixels[newIndex + 1]))
            let db = abs(Int(old.pixels[oldIndex + 2]) - Int(new.pixels[newIndex + 2]))
            let pixelDelta = max(dr, dg, db)
            let intensity = UInt8(min(255, pixelDelta * 4))
            if pixelDelta > badPixelThreshold {
                pixels[diffIndex] = 255
                pixels[diffIndex + 1] = UInt8(max(0, 120 - pixelDelta / 2))
                pixels[diffIndex + 2] = UInt8(max(0, 120 - pixelDelta / 2))
            } else {
                pixels[diffIndex] = intensity
                pixels[diffIndex + 1] = intensity
                pixels[diffIndex + 2] = intensity
            }
            pixels[diffIndex + 3] = 255
        }
    }

    guard let context = CGContext(
        data: &pixels,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ), let image = context.makeImage() else {
        throw NSError(domain: "ScreenshotParity", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to allocate diff image"])
    }

    let url = URL(fileURLWithPath: path)
    guard
        let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil)
    else {
        throw NSError(domain: "ScreenshotParity", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to create diff image destination: \(path)"])
    }
    CGImageDestinationAddImage(destination, image, nil)
    if !CGImageDestinationFinalize(destination) {
        throw NSError(domain: "ScreenshotParity", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unable to write diff image: \(path)"])
    }
}

do {
    let old = try loadPixels(oldPath)
    let new = try loadPixels(newPath)
    let compareWidth = min(old.width, new.width)
    let compareHeight = min(old.height, new.height)
    let dimensionsMatch = old.width == new.width && old.height == new.height

    let regions = [
        Region(name: "full", x: 0, y: 0, width: compareWidth, height: compareHeight),
        clampRegion(name: "headerControls", x: 0.05, y: 0.08, width: 0.55, height: 0.15, imageWidth: compareWidth, imageHeight: compareHeight),
        clampRegion(name: "composeCanvas", x: 0.07, y: 0.21, width: 0.86, height: 0.69, imageWidth: compareWidth, imageHeight: compareHeight),
        clampRegion(name: "swingIsland", x: 0.62, y: 0.24, width: 0.33, height: 0.21, imageWidth: compareWidth, imageHeight: compareHeight),
        clampRegion(name: "rightProbeStrip", x: 0.70, y: 0.22, width: 0.26, height: 0.68, imageWidth: compareWidth, imageHeight: compareHeight),
    ]
    let fullMetrics = metrics(old: old, new: new, region: regions[0], badPixelThreshold: badPixelThreshold)
    try writeDiffImage(old: old, new: new, width: compareWidth, height: compareHeight, path: diffPath, badPixelThreshold: badPixelThreshold)

    print("JBR_SKIA_SCREENSHOT_PARITY width=\(compareWidth) height=\(compareHeight) oldWidth=\(old.width) oldHeight=\(old.height) newWidth=\(new.width) newHeight=\(new.height) dimensionsMatch=\(dimensionsMatch) avgDelta=\(String(format: "%.3f", fullMetrics.averageDelta)) maxDelta=\(fullMetrics.maxDelta) badPixels=\(fullMetrics.badPixels) badPixelRatio=\(String(format: "%.5f", fullMetrics.badPixelRatio)) diffImage=\(diffPath.isEmpty ? "none" : URL(fileURLWithPath: diffPath).lastPathComponent)")
    for region in regions {
        let regionMetrics = metrics(old: old, new: new, region: region, badPixelThreshold: badPixelThreshold)
        print("JBR_SKIA_SCREENSHOT_PARITY_REGION name=\(region.name) x=\(region.x) y=\(region.y) width=\(region.width) height=\(region.height) avgDelta=\(String(format: "%.3f", regionMetrics.averageDelta)) maxDelta=\(regionMetrics.maxDelta) badPixels=\(regionMetrics.badPixels) badPixelRatio=\(String(format: "%.5f", regionMetrics.badPixelRatio))")
    }

    if fullMetrics.averageDelta > maxAverageDelta || fullMetrics.badPixelRatio > maxBadPixelRatio {
        fputs("Screenshot parity exceeded thresholds: avgDelta \(fullMetrics.averageDelta) > \(maxAverageDelta) or badPixelRatio \(fullMetrics.badPixelRatio) > \(maxBadPixelRatio)\n", stderr)
        exit(1)
    }
} catch {
    fputs("\(error.localizedDescription)\n", stderr)
    exit(2)
}
SWIFT
