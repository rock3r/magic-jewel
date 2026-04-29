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

var green = 0
var blue = 0
var purple = 0
var yellow = 0
var orange = 0
var white = 0
var topText = 0
var bottomText = 0

func isDarkText(r: Int, g: Int, b: Int) -> Bool {
    return r < 55 && g < 55 && b < 55
}

func inRect(x: Int, y: Int, left: Int, top: Int, right: Int, bottom: Int) -> Bool {
    return x >= left && x < right && y >= top && y < bottom
}

let topTextRect = (
    left: width / 16,
    top: height / 12,
    right: width * 7 / 16,
    bottom: height / 5
)
let bottomTextRect = (
    left: width / 16,
    top: height * 7 / 10,
    right: width / 2,
    bottom: height * 17 / 20
)

for y in 0..<height {
    for x in 0..<width {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let r = Int(pixels[offset])
        let g = Int(pixels[offset + 1])
        let b = Int(pixels[offset + 2])

        if g > 110 && r < 90 && b < 110 {
            green += 1
        }
        if b > 110 && r < 100 && g < 120 {
            blue += 1
        }
        if r > 90 && b > 140 && g < 110 {
            purple += 1
        }
        if r > 180 && g > 130 && b < 90 {
            yellow += 1
        }
        if r > 200 && g > 100 && g < 190 && b < 120 {
            orange += 1
        }
        if r > 220 && g > 220 && b > 220 {
            white += 1
        }
        if isDarkText(r: r, g: g, b: b) {
            if inRect(x: x, y: y, left: topTextRect.left, top: topTextRect.top, right: topTextRect.right, bottom: topTextRect.bottom) {
                topText += 1
            }
            if inRect(x: x, y: y, left: bottomTextRect.left, top: bottomTextRect.top, right: bottomTextRect.right, bottom: bottomTextRect.bottom) {
                bottomText += 1
            }
        }
    }
}

print("JBR_SKIA_COMMAND_SCREENSHOT_COUNTS green=\(green) blue=\(blue) purple=\(purple) yellow=\(yellow) orange=\(orange) white=\(white) topText=\(topText) bottomText=\(bottomText)")

let checks: [(String, Int, Int)] = [
    ("green", green, 10000),
    ("blue", blue, 10000),
    ("purple", purple, 1000),
    ("yellow", yellow, 500),
    ("orange", orange, 1000),
    ("white", white, 500),
    ("topText", topText, 900),
    ("bottomText", bottomText, 1200),
]

for (name, count, minimum) in checks where count < minimum {
    fputs("Expected at least \(minimum) \(name) pixels, found \(count)\n", stderr)
    exit(1)
}
SWIFT
