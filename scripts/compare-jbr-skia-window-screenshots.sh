#!/usr/bin/env bash
set -euo pipefail

OLD_IMAGE="${1:?Usage: $0 <old-window.png> <new-window.png>}"
NEW_IMAGE="${2:?Usage: $0 <old-window.png> <new-window.png>}"
MAX_AVG_DELTA="${MAX_AVG_DELTA:-8.0}"
MAX_BAD_PIXEL_RATIO="${MAX_BAD_PIXEL_RATIO:-0.04}"
BAD_PIXEL_THRESHOLD="${BAD_PIXEL_THRESHOLD:-32}"

/usr/bin/swift - "${OLD_IMAGE}" "${NEW_IMAGE}" "${MAX_AVG_DELTA}" "${MAX_BAD_PIXEL_RATIO}" "${BAD_PIXEL_THRESHOLD}" <<'SWIFT'
import CoreGraphics
import Foundation
import ImageIO

let oldPath = CommandLine.arguments[1]
let newPath = CommandLine.arguments[2]
let maxAverageDelta = Double(CommandLine.arguments[3]) ?? 8.0
let maxBadPixelRatio = Double(CommandLine.arguments[4]) ?? 0.04
let badPixelThreshold = Int(CommandLine.arguments[5]) ?? 32

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

do {
    let old = try loadPixels(oldPath)
    let new = try loadPixels(newPath)
    guard old.width == new.width && old.height == new.height else {
        fputs("Image dimensions differ: old=\(old.width)x\(old.height) new=\(new.width)x\(new.height)\n", stderr)
        exit(1)
    }

    let pixelCount = old.width * old.height
    var totalDelta = 0
    var maxDelta = 0
    var badPixels = 0

    for index in stride(from: 0, to: old.pixels.count, by: 4) {
        let dr = abs(Int(old.pixels[index]) - Int(new.pixels[index]))
        let dg = abs(Int(old.pixels[index + 1]) - Int(new.pixels[index + 1]))
        let db = abs(Int(old.pixels[index + 2]) - Int(new.pixels[index + 2]))
        let pixelDelta = max(dr, dg, db)
        totalDelta += dr + dg + db
        maxDelta = max(maxDelta, pixelDelta)
        if pixelDelta > badPixelThreshold {
            badPixels += 1
        }
    }

    let averageDelta = Double(totalDelta) / Double(pixelCount * 3)
    let badPixelRatio = Double(badPixels) / Double(pixelCount)
    print("JBR_SKIA_SCREENSHOT_PARITY width=\(old.width) height=\(old.height) avgDelta=\(String(format: "%.3f", averageDelta)) maxDelta=\(maxDelta) badPixels=\(badPixels) badPixelRatio=\(String(format: "%.5f", badPixelRatio))")

    if averageDelta > maxAverageDelta || badPixelRatio > maxBadPixelRatio {
        fputs("Screenshot parity exceeded thresholds: avgDelta \(averageDelta) > \(maxAverageDelta) or badPixelRatio \(badPixelRatio) > \(maxBadPixelRatio)\n", stderr)
        exit(1)
    }
} catch {
    fputs("\(error.localizedDescription)\n", stderr)
    exit(2)
}
SWIFT
