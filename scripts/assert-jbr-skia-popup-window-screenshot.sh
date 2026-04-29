#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: $0 <popup-window-screenshot.png>}"

/usr/bin/swift - "${IMAGE}" <<'SWIFT'
import CoreGraphics
import Foundation
import ImageIO

let imagePath = CommandLine.arguments[1]
let url = URL(fileURLWithPath: imagePath)

guard
    let source = CGImageSourceCreateWithURL(url as CFURL, nil),
    let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
else {
    fputs("Unable to read image: \(imagePath)\n", stderr)
    exit(2)
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
    fputs("Unable to allocate bitmap context\n", stderr)
    exit(2)
}

context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

var white = 0
var popupPink = 0
var popupCyan = 0
var darkText = 0

for y in 0..<height {
    for x in 0..<width {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let r = Int(pixels[offset])
        let g = Int(pixels[offset + 1])
        let b = Int(pixels[offset + 2])

        if r > 230 && g > 230 && b > 230 {
            white += 1
        }
        if r > 190 && g < 120 && b > 120 {
            popupPink += 1
        }
        if r < 80 && g > 170 && b > 170 {
            popupCyan += 1
        }
        if r < 70 && g < 70 && b < 70 {
            darkText += 1
        }
    }
}

print("JBR_SKIA_POPUP_WINDOW_SCREENSHOT_COUNTS white=\(white) popupPink=\(popupPink) popupCyan=\(popupCyan) darkText=\(darkText) width=\(width) height=\(height)")

let checks: [(String, Int, Int)] = [
    ("white", white, 1000),
    ("popupPink", popupPink, 200),
    ("popupCyan", popupCyan, 80),
    ("darkText", darkText, 100),
]

for (name, count, minimum) in checks where count < minimum {
    fputs("Expected at least \(minimum) \(name) pixels, found \(count)\n", stderr)
    exit(1)
}
SWIFT
