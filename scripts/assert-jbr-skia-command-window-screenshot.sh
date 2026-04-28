#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: $0 <window-screenshot.png>}"

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

var dark = 0
var cyan = 0
var yellow = 0
var pink = 0

for y in 0..<height {
    for x in 0..<width {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let r = Int(pixels[offset])
        let g = Int(pixels[offset + 1])
        let b = Int(pixels[offset + 2])

        if r < 40 && g < 55 && b < 75 {
            dark += 1
        }
        if r < 60 && g > 140 && b > 140 {
            cyan += 1
        }
        if r > 180 && g > 130 && b < 90 {
            yellow += 1
        }
        if r > 180 && g < 100 && b > 100 {
            pink += 1
        }
    }
}

print("JBR_SKIA_COMMAND_SCREENSHOT_COUNTS dark=\(dark) cyan=\(cyan) yellow=\(yellow) pink=\(pink)")

let checks: [(String, Int, Int)] = [
    ("dark", dark, 500000),
    ("cyan", cyan, 20000),
    ("yellow", yellow, 5000),
    ("pink", pink, 5000),
]

for (name, count, minimum) in checks where count < minimum {
    fputs("Expected at least \(minimum) \(name) pixels, found \(count)\n", stderr)
    exit(1)
}
SWIFT
