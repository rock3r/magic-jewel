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
var topTextMinX = width
var topTextMinY = height
var topTextMaxX = 0
var topTextMaxY = 0
var bottomTextMinX = width
var bottomTextMinY = height
var bottomTextMaxX = 0
var bottomTextMaxY = 0
var popupPink = 0
var popupCyan = 0
var menuWhite = 0
var menuYellow = 0
var probeTopLeftCyan = 0
var probeBottomLeftCyan = 0
var probeRightPurple = 0
var probeRightOrange = 0
var probeRightCyan = 0
var probeRightYellow = 0
var probeRightDark = 0
var probeRightShadow = 0
var blendModeYellow = 0
var blendModeMultiply = 0
var blendModeScreen = 0
var blendModeOverlay = 0
var blendModeDarken = 0
var blendModeLighten = 0
var blendModeDifference = 0
var blendModeExclusion = 0
var blendModeColorDodge = 0
var blendModeColorBurn = 0
var blendModeHardlight = 0
var blendModeSoftlight = 0
var blendModeHue = 0
var blendModeSaturation = 0
var blendModeColor = 0
var blendModeLuminosity = 0
var paragraphCentered = 0
var paragraphItalicRight = 0
var paragraphRtl = 0
var paragraphOverflow = 0
var paragraphDecorated = 0
var primaryButtonWhiteText = 0
var primaryButtonDarkText = 0
var primaryButtonTextMinX = width
var primaryButtonTextMinY = height
var primaryButtonTextMaxX = 0
var primaryButtonTextMaxY = 0
var markdownReadmeLogoGray = 0
var buttonsBodyIconTileVeryLight = 0
var buttonsBodyIconGlyphPixels = 0
var buttonsSelectedNavBackground = 0

func isDarkText(r: Int, g: Int, b: Int) -> Bool {
    return r < 55 && g < 55 && b < 55
}

func isWhiteText(r: Int, g: Int, b: Int) -> Bool {
    return r > 215 && g > 215 && b > 215
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
let menuRect = (
    left: width * 11 / 20,
    top: height / 5,
    right: width * 39 / 40,
    bottom: height / 2
)
let probeTopLeftRect = (
    left: width / 12,
    top: height / 5,
    right: width / 5,
    bottom: height * 2 / 5
)
let probeBottomLeftRect = (
    left: width / 10,
    top: height * 7 / 10,
    right: width / 5,
    bottom: height * 17 / 20
)
let probeRightRect = (
    left: width * 3 / 4,
    top: height * 13 / 20,
    right: width * 39 / 40,
    bottom: height * 17 / 20
)
let blendModeRect = (
    left: width / 2,
    top: height / 5,
    right: width * 49 / 50,
    bottom: height * 17 / 20
)
let paragraphCenteredRect = (
    left: width / 14,
    top: height * 63 / 100,
    right: width * 7 / 20,
    bottom: height * 67 / 100
)
let paragraphItalicRightRect = (
    left: width / 7,
    top: height * 66 / 100,
    right: width * 7 / 20,
    bottom: height * 70 / 100
)
let paragraphRtlRect = (
    left: width / 14,
    top: height * 70 / 100,
    right: width * 7 / 20,
    bottom: height * 74 / 100
)
let paragraphOverflowRect = (
    left: width / 14,
    top: height * 74 / 100,
    right: width * 7 / 20,
    bottom: height * 78 / 100
)
let paragraphDecoratedRect = (
    left: width / 14,
    top: height * 78 / 100,
    right: width * 7 / 20,
    bottom: height * 82 / 100
)
let primaryButtonTextRect = (
    left: width * 7 / 200,
    top: height * 123 / 1000,
    right: width * 17 / 200,
    bottom: height * 157 / 1000
)
let markdownReadmeLogoRect = (
    left: width / 25,
    top: height / 5,
    right: width / 4,
    bottom: height / 2
)
let buttonsBodyIconRects = [
    (left: width * 109 / 1000, top: height * 452 / 1000, right: width * 129 / 1000, bottom: height * 491 / 1000),
    (left: width * 209 / 1000, top: height * 452 / 1000, right: width * 229 / 1000, bottom: height * 491 / 1000),
    (left: width * 513 / 1000, top: height * 452 / 1000, right: width * 533 / 1000, bottom: height * 491 / 1000),
    (left: width * 582 / 1000, top: height * 452 / 1000, right: width * 602 / 1000, bottom: height * 491 / 1000),
    (left: width * 111 / 1000, top: height * 542 / 1000, right: width * 131 / 1000, bottom: height * 577 / 1000),
    (left: width * 219 / 1000, top: height * 542 / 1000, right: width * 239 / 1000, bottom: height * 577 / 1000),
    (left: width * 312 / 1000, top: height * 542 / 1000, right: width * 332 / 1000, bottom: height * 577 / 1000),
    (left: width * 400 / 1000, top: height * 542 / 1000, right: width * 420 / 1000, bottom: height * 577 / 1000),
    (left: width * 480 / 1000, top: height * 542 / 1000, right: width * 500 / 1000, bottom: height * 577 / 1000),
]
let buttonsSelectedNavRect = (
    left: 0,
    top: height * 39 / 1000,
    right: width * 30 / 1000,
    bottom: height * 78 / 1000
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
        if r > 190 && g < 120 && b > 120 {
            popupPink += 1
        }
        if r < 80 && g > 170 && b > 170 {
            popupCyan += 1
        }
        if inRect(x: x, y: y, left: menuRect.left, top: menuRect.top, right: menuRect.right, bottom: menuRect.bottom) {
            if r > 240 && g > 240 && b > 240 {
                menuWhite += 1
            }
            if r > 220 && g > 160 && b < 90 {
                menuYellow += 1
            }
        }
        if inRect(x: x, y: y, left: probeTopLeftRect.left, top: probeTopLeftRect.top, right: probeTopLeftRect.right, bottom: probeTopLeftRect.bottom) {
            if r < 80 && g > 170 && b > 170 {
                probeTopLeftCyan += 1
            }
        }
        if inRect(x: x, y: y, left: probeBottomLeftRect.left, top: probeBottomLeftRect.top, right: probeBottomLeftRect.right, bottom: probeBottomLeftRect.bottom) {
            if r < 80 && g > 170 && b > 170 {
                probeBottomLeftCyan += 1
            }
        }
        if inRect(x: x, y: y, left: probeRightRect.left, top: probeRightRect.top, right: probeRightRect.right, bottom: probeRightRect.bottom) {
            if r > 90 && b > 140 && g < 190 && b > g {
                probeRightPurple += 1
            }
            if r > 200 && g > 110 && g < 190 && b < 120 {
                probeRightOrange += 1
            }
            if r < 80 && g > 170 && b > 170 {
                probeRightCyan += 1
            }
            if r > 180 && g > 130 && b < 90 {
                probeRightYellow += 1
            }
            if r < 60 && g < 60 && b < 60 {
                probeRightDark += 1
            }
            if r < 80 && g < 115 && b < 205 {
                probeRightShadow += 1
            }
        }
        if inRect(x: x, y: y, left: blendModeRect.left, top: blendModeRect.top, right: blendModeRect.right, bottom: blendModeRect.bottom) {
            if r > 220 && g > 150 && b < 120 {
                blendModeYellow += 1
            }
            if r > 80 && r < 170 && g < 90 && b < 120 {
                blendModeMultiply += 1
            }
            if r > 230 && g > 210 && b > 150 {
                blendModeScreen += 1
            }
            if r > 220 && g > 120 && b > 180 {
                blendModeOverlay += 1
            }
            if r >= 70 && r <= 160 && g >= 20 && g <= 100 && b >= 45 && b <= 130 {
                blendModeDarken += 1
            }
            if r > 230 && g > 180 && b > 180 {
                blendModeLighten += 1
            }
            if r >= 95 && r <= 170 && g >= 120 && g <= 200 && b >= 145 && b <= 230 {
                blendModeDifference += 1
            }
            if r >= 190 && r <= 245 && g >= 135 && g <= 195 && b >= 135 && b <= 205 {
                blendModeExclusion += 1
            }
            if r >= 40 && r <= 95 && g >= 80 && g <= 135 && b >= 225 {
                blendModeColorDodge += 1
            }
            if r >= 230 && g >= 90 && g <= 150 && b >= 35 && b <= 95 {
                blendModeColorBurn += 1
            }
            if r >= 15 && r <= 55 && g >= 20 && g <= 70 && b >= 225 {
                blendModeHardlight += 1
            }
            if r >= 240 && g >= 190 && g <= 230 && b >= 100 && b <= 155 {
                blendModeSoftlight += 1
            }
            if r >= 110 && r <= 230 && g <= 130 && b >= 120 {
                blendModeHue += 1
            }
            if r >= 150 && r <= 230 && g >= 150 && g <= 230 && b >= 120 && b <= 205 {
                blendModeSaturation += 1
            }
            if r <= 100 && g >= 90 && g <= 180 && b >= 190 {
                blendModeColor += 1
            }
            if r >= 85 && r <= 170 && g >= 55 && g <= 135 && b <= 90 {
                blendModeLuminosity += 1
            }
        }
        if inRect(x: x, y: y, left: primaryButtonTextRect.left, top: primaryButtonTextRect.top, right: primaryButtonTextRect.right, bottom: primaryButtonTextRect.bottom) {
            if isWhiteText(r: r, g: g, b: b) {
                primaryButtonWhiteText += 1
                primaryButtonTextMinX = min(primaryButtonTextMinX, x)
                primaryButtonTextMinY = min(primaryButtonTextMinY, y)
                primaryButtonTextMaxX = max(primaryButtonTextMaxX, x)
                primaryButtonTextMaxY = max(primaryButtonTextMaxY, y)
            }
            if isDarkText(r: r, g: g, b: b) {
                primaryButtonDarkText += 1
            }
        }
        if inRect(x: x, y: y, left: markdownReadmeLogoRect.left, top: markdownReadmeLogoRect.top, right: markdownReadmeLogoRect.right, bottom: markdownReadmeLogoRect.bottom) {
            if abs(r - g) <= 8 && abs(g - b) <= 8 && r >= 120 && r <= 210 {
                markdownReadmeLogoGray += 1
            }
        }
        if inRect(x: x, y: y, left: buttonsSelectedNavRect.left, top: buttonsSelectedNavRect.top, right: buttonsSelectedNavRect.right, bottom: buttonsSelectedNavRect.bottom) {
            if abs(r - g) <= 8 && abs(g - b) <= 8 && r >= 165 && r <= 245 {
                buttonsSelectedNavBackground += 1
            }
        }
        for rect in buttonsBodyIconRects where inRect(x: x, y: y, left: rect.left, top: rect.top, right: rect.right, bottom: rect.bottom) {
            if r > 248 && g > 248 && b > 248 {
                buttonsBodyIconTileVeryLight += 1
            }
            if (r < 120 && g < 130 && b < 160) || (b > 135 && r < 160 && g < 180 && b > r + 15) {
                buttonsBodyIconGlyphPixels += 1
            }
        }
        if isDarkText(r: r, g: g, b: b) {
            if inRect(x: x, y: y, left: paragraphCenteredRect.left, top: paragraphCenteredRect.top, right: paragraphCenteredRect.right, bottom: paragraphCenteredRect.bottom) {
                paragraphCentered += 1
            }
            if inRect(x: x, y: y, left: paragraphItalicRightRect.left, top: paragraphItalicRightRect.top, right: paragraphItalicRightRect.right, bottom: paragraphItalicRightRect.bottom) {
                paragraphItalicRight += 1
            }
            if inRect(x: x, y: y, left: paragraphRtlRect.left, top: paragraphRtlRect.top, right: paragraphRtlRect.right, bottom: paragraphRtlRect.bottom) {
                paragraphRtl += 1
            }
            if inRect(x: x, y: y, left: paragraphOverflowRect.left, top: paragraphOverflowRect.top, right: paragraphOverflowRect.right, bottom: paragraphOverflowRect.bottom) {
                paragraphOverflow += 1
            }
            if inRect(x: x, y: y, left: paragraphDecoratedRect.left, top: paragraphDecoratedRect.top, right: paragraphDecoratedRect.right, bottom: paragraphDecoratedRect.bottom) {
                paragraphDecorated += 1
            }
            if inRect(x: x, y: y, left: topTextRect.left, top: topTextRect.top, right: topTextRect.right, bottom: topTextRect.bottom) {
                topText += 1
                topTextMinX = min(topTextMinX, x)
                topTextMinY = min(topTextMinY, y)
                topTextMaxX = max(topTextMaxX, x)
                topTextMaxY = max(topTextMaxY, y)
            }
            if inRect(x: x, y: y, left: bottomTextRect.left, top: bottomTextRect.top, right: bottomTextRect.right, bottom: bottomTextRect.bottom) {
                bottomText += 1
                bottomTextMinX = min(bottomTextMinX, x)
                bottomTextMinY = min(bottomTextMinY, y)
                bottomTextMaxX = max(bottomTextMaxX, x)
                bottomTextMaxY = max(bottomTextMaxY, y)
            }
        }
    }
}

print("JBR_SKIA_COMMAND_SCREENSHOT_COUNTS green=\(green) blue=\(blue) purple=\(purple) yellow=\(yellow) orange=\(orange) white=\(white) topText=\(topText) bottomText=\(bottomText) topTextBox=\(topTextMinX),\(topTextMinY),\(topTextMaxX),\(topTextMaxY) bottomTextBox=\(bottomTextMinX),\(bottomTextMinY),\(bottomTextMaxX),\(bottomTextMaxY) primaryButtonWhiteText=\(primaryButtonWhiteText) primaryButtonDarkText=\(primaryButtonDarkText) primaryButtonTextBox=\(primaryButtonTextMinX),\(primaryButtonTextMinY),\(primaryButtonTextMaxX),\(primaryButtonTextMaxY) popupPink=\(popupPink) popupCyan=\(popupCyan) menuWhite=\(menuWhite) menuYellow=\(menuYellow) probeTopLeftCyan=\(probeTopLeftCyan) probeBottomLeftCyan=\(probeBottomLeftCyan) probeRightPurple=\(probeRightPurple) probeRightOrange=\(probeRightOrange) probeRightCyan=\(probeRightCyan) probeRightYellow=\(probeRightYellow) probeRightDark=\(probeRightDark) probeRightShadow=\(probeRightShadow) blendModeYellow=\(blendModeYellow) blendModeMultiply=\(blendModeMultiply) blendModeScreen=\(blendModeScreen) blendModeOverlay=\(blendModeOverlay) blendModeDarken=\(blendModeDarken) blendModeLighten=\(blendModeLighten) blendModeDifference=\(blendModeDifference) blendModeExclusion=\(blendModeExclusion) blendModeColorDodge=\(blendModeColorDodge) blendModeColorBurn=\(blendModeColorBurn) blendModeHardlight=\(blendModeHardlight) blendModeSoftlight=\(blendModeSoftlight) blendModeHue=\(blendModeHue) blendModeSaturation=\(blendModeSaturation) blendModeColor=\(blendModeColor) blendModeLuminosity=\(blendModeLuminosity) paragraphCentered=\(paragraphCentered) paragraphItalicRight=\(paragraphItalicRight) paragraphRtl=\(paragraphRtl) paragraphOverflow=\(paragraphOverflow) paragraphDecorated=\(paragraphDecorated) markdownReadmeLogoGray=\(markdownReadmeLogoGray) buttonsBodyIconTileVeryLight=\(buttonsBodyIconTileVeryLight) buttonsBodyIconGlyphPixels=\(buttonsBodyIconGlyphPixels) buttonsSelectedNavBackground=\(buttonsSelectedNavBackground)")

let composeTextEnabled = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_TEXT"] != "false"
let markdownContent = ProcessInfo.processInfo.environment["JEWEL_STANDALONE_MARKDOWN_CONTENT"] ?? ""
let markdownReadmeProbe =
    ProcessInfo.processInfo.environment["JEWEL_STANDALONE_INITIAL_VIEW"] == "Markdown" &&
    (markdownContent.hasPrefix("readme") || markdownContent.hasPrefix("rawReadme"))
let rawMarkdownReadmeProbe = markdownReadmeProbe && markdownContent.hasPrefix("rawReadme")
let buttonsComponentProbe = ProcessInfo.processInfo.environment["JEWEL_STANDALONE_INITIAL_COMPONENT"] == "Buttons"
let imageArea = width * height
let minTopTextPixels =
    Int(ProcessInfo.processInfo.environment["MIN_TOP_TEXT_PIXELS"] ?? "") ?? min(900, max(500, imageArea / 1100))
let minBottomTextPixels =
    Int(ProcessInfo.processInfo.environment["MIN_BOTTOM_TEXT_PIXELS"] ?? "") ?? min(1200, max(700, imageArea / 900))
let minTopTextHeight =
    Int(ProcessInfo.processInfo.environment["MIN_TOP_TEXT_HEIGHT"] ?? "") ?? min(30, max(20, height / 30))
let minBottomTextHeight =
    Int(ProcessInfo.processInfo.environment["MIN_BOTTOM_TEXT_HEIGHT"] ?? "") ?? min(24, max(22, height / 60))
var checks: [(String, Int, Int)]
if markdownReadmeProbe {
    checks = [
        ("white", white, 500),
        ("topText", topText, minTopTextPixels),
    ]
} else if buttonsComponentProbe {
    checks = [
        ("white", white, 500),
        ("topText", topText, minTopTextPixels),
        ("primaryButtonWhiteText", primaryButtonWhiteText, 180),
        ("buttonsBodyIconGlyphPixels", buttonsBodyIconGlyphPixels, 200),
    ]
} else {
    checks = [
        ("green", green, 10000),
        ("blue", blue, 10000),
        ("purple", purple, 1000),
        ("yellow", yellow, 500),
        ("orange", orange, 1000),
        ("white", white, 500),
    ]
}
if composeTextEnabled && !markdownReadmeProbe && !buttonsComponentProbe {
    checks.append(("topText", topText, minTopTextPixels))
    checks.append(("bottomText", bottomText, minBottomTextPixels))
    checks.append(("primaryButtonWhiteText", primaryButtonWhiteText, 180))
}
if rawMarkdownReadmeProbe {
    checks.append(("green", green, 1000))
    checks.append(("yellow", yellow, 1000))
    checks.append(("orange", orange, 1000))
    checks.append(("purple", purple, 1000))
} else if markdownReadmeProbe && markdownReadmeLogoGray > 10_000 {
    fputs("Unexpected local README logo block in Markdown preview: markdownReadmeLogoGray=\(markdownReadmeLogoGray)\n", stderr)
    exit(1)
}

let nativeTextProbe = ProcessInfo.processInfo.environment["JBR_SKIA_NATIVE_TEXT"] == "true"
let paragraphLayoutProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_PARAGRAPH_LAYOUT_TEXT"] == "true"
let popupStress = ProcessInfo.processInfo.environment["MAGIC_JEWEL_POPUP_STRESS"] == "true"
let menuStress = ProcessInfo.processInfo.environment["MAGIC_JEWEL_MENU_STRESS"] == "true"
let minimumTextWidth = min(width / 5, 360)

var textBoxChecks: [(String, Bool)] = []
if composeTextEnabled && !markdownReadmeProbe && !buttonsComponentProbe && !popupStress && !menuStress {
    let primaryButtonTextCenterX = (primaryButtonTextMinX + primaryButtonTextMaxX) / 2
    let primaryButtonTextCenterY = (primaryButtonTextMinY + primaryButtonTextMaxY) / 2
    let expectedPrimaryButtonTextCenterX = (primaryButtonTextRect.left + primaryButtonTextRect.right) / 2
    let expectedPrimaryButtonTextCenterY = (primaryButtonTextRect.top + primaryButtonTextRect.bottom) / 2
    textBoxChecks.append(contentsOf: [
        ("topTextWidth", topTextMaxX - topTextMinX >= minimumTextWidth),
        ("topTextHeight", topTextMaxY - topTextMinY >= minTopTextHeight),
        ("topTextVerticalAnchor", topTextMinY <= topTextRect.top + height / 12 && topTextMaxY >= topTextRect.top + height / 24),
        ("bottomTextWidth", bottomTextMaxX - bottomTextMinX >= minimumTextWidth),
        ("bottomTextHeight", bottomTextMaxY - bottomTextMinY >= minBottomTextHeight),
        ("bottomTextVerticalAnchor", nativeTextProbe && paragraphLayoutProbe
            ? bottomTextMinY <= bottomTextRect.bottom && bottomTextMaxY >= bottomTextRect.top + height / 20
            : bottomTextMinY <= bottomTextRect.bottom && bottomTextMaxY >= bottomTextRect.bottom - height / 15),
        ("primaryButtonTextColor", primaryButtonDarkText <= max(20, primaryButtonWhiteText / 8)),
        ("primaryButtonTextWidth", primaryButtonTextMaxX - primaryButtonTextMinX >= width / 45),
        ("primaryButtonTextHorizontalCenter", abs(primaryButtonTextCenterX - expectedPrimaryButtonTextCenterX) <= width / 80),
        ("primaryButtonTextVerticalCenter", abs(primaryButtonTextCenterY - expectedPrimaryButtonTextCenterY) <= height / 70),
    ])
}

let transformProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_TRANSFORM"] == "true"
let clipProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_CLIP"] == "true"
let clipOutProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_CLIP_OUT"] == "true"
let clipPathProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_CLIP_PATH"] == "true"
let minClipPathProbeRightCyan =
    Int(ProcessInfo.processInfo.environment["MIN_CLIP_PATH_PROBE_RIGHT_CYAN"] ?? "") ?? 4000
let graphicsLayerClipProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_CLIP"] == "true"
let graphicsLayerRoundClipProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_ROUND_CLIP"] == "true"
let graphicsLayerPathClipProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_PATH_CLIP"] == "true"
let graphicsLayerColorFilterProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_FILTER"] == "true"
let graphicsLayerColorMatrixFilterProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_COLOR_MATRIX_FILTER"] == "true"
let graphicsLayerShadowProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_GRAPHICS_LAYER_SHADOW"] == "true"
let drawPathProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_DRAW_PATH"] == "true"
let drawArcProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_DRAW_ARC"] == "true"
let drawRoundRectProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_DRAW_ROUND_RECT"] == "true"
let imageShaderProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_IMAGE_SHADER"] == "true"
let invalidImageShaderProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_INVALID_IMAGE_SHADER_IMAGE"] == "true"
let minImageShaderProbeRightDark =
    Int(ProcessInfo.processInfo.environment["MIN_IMAGE_SHADER_PROBE_RIGHT_DARK"] ?? "") ?? 2000
let minImageShaderProbeRightCyan =
    Int(ProcessInfo.processInfo.environment["MIN_IMAGE_SHADER_PROBE_RIGHT_CYAN"] ?? "") ?? 800
let minInvalidImageShaderProbeRightPurple =
    Int(ProcessInfo.processInfo.environment["MIN_INVALID_IMAGE_SHADER_PROBE_RIGHT_PURPLE"] ?? "") ?? 8000
let minTransformProbeBottomLeftCyan =
    Int(ProcessInfo.processInfo.environment["MIN_TRANSFORM_PROBE_BOTTOM_LEFT_CYAN"] ?? "") ?? 200
let linearGradientStrokeProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_STROKE"] == "true"
let minLinearGradientStrokeProbeRightOrange =
    Int(ProcessInfo.processInfo.environment["MIN_LINEAR_GRADIENT_STROKE_PROBE_RIGHT_ORANGE"] ?? "") ?? 500
let linearGradientSurfaceProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT"] == "true"
let minLinearGradientSurfaceProbeRightPurple =
    Int(ProcessInfo.processInfo.environment["MIN_LINEAR_GRADIENT_SURFACE_PROBE_RIGHT_PURPLE"] ?? "") ?? 3000
let linearGradientRoundRectSurfaceProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_ROUND_RECT"] == "true"
let radialGradientSurfaceProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT"] == "true"
let radialGradientRoundRectSurfaceProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_ROUND_RECT"] == "true"
let sweepGradientRectProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT"] == "true"
let sweepGradientRoundRectSurfaceProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_ROUND_RECT"] == "true"
let linearGradientPathProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_LINEAR_GRADIENT_PATH"] == "true"
let minLinearGradientPathProbePixels =
    Int(ProcessInfo.processInfo.environment["MIN_LINEAR_GRADIENT_PATH_PROBE_PIXELS"] ?? "") ?? 500
let radialGradientPathProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_RADIAL_GRADIENT_PATH"] == "true"
let minRadialGradientPathProbePixels =
    Int(ProcessInfo.processInfo.environment["MIN_RADIAL_GRADIENT_PATH_PROBE_PIXELS"] ?? "") ?? 350
let sweepGradientPathProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_SWEEP_GRADIENT_PATH"] == "true"
let minSweepGradientPathProbePixels =
    Int(ProcessInfo.processInfo.environment["MIN_SWEEP_GRADIENT_PATH_PROBE_PIXELS"] ?? "") ?? 800
let gradientPathStrokeProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_GRADIENT_PATH_STROKE"] == "true"
let blendModeProbe = ProcessInfo.processInfo.environment["MAGIC_JEWEL_COMPOSE_BLEND_MODE"] == "true"
let popupChecks: [(String, Int, Int)] = popupStress
    ? [
        ("popupPink", popupPink, 200),
        ("popupCyan", popupCyan, 80),
      ]
    : []
let menuChecks: [(String, Int, Int)] = menuStress
    ? [
        ("menuWhite", menuWhite, 8000),
        ("menuYellow", menuYellow, 500),
      ]
    : []
var probeChecks: [(String, Int, Int)] = []
if paragraphLayoutProbe {
    let minParagraphCentered =
        Int(ProcessInfo.processInfo.environment["MIN_PARAGRAPH_CENTERED_PIXELS"] ?? "") ?? 700
    let minParagraphItalicRight =
        Int(ProcessInfo.processInfo.environment["MIN_PARAGRAPH_ITALIC_RIGHT_PIXELS"] ?? "") ?? 150
    let minParagraphRtl =
        Int(ProcessInfo.processInfo.environment["MIN_PARAGRAPH_RTL_PIXELS"] ?? "") ?? 1500
    let minParagraphOverflow =
        Int(ProcessInfo.processInfo.environment["MIN_PARAGRAPH_OVERFLOW_PIXELS"] ?? "") ?? 1400
    let minParagraphDecorated =
        Int(ProcessInfo.processInfo.environment["MIN_PARAGRAPH_DECORATED_PIXELS"] ?? "") ?? 700
    probeChecks.append(("paragraphCentered", paragraphCentered, minParagraphCentered))
    probeChecks.append(("paragraphItalicRight", paragraphItalicRight, minParagraphItalicRight))
    probeChecks.append(("paragraphRtl", paragraphRtl, minParagraphRtl))
    probeChecks.append(("paragraphOverflow", paragraphOverflow, minParagraphOverflow))
    probeChecks.append(("paragraphDecorated", paragraphDecorated, minParagraphDecorated))
}
if transformProbe {
    probeChecks.append(("probeBottomLeftCyan", probeBottomLeftCyan, minTransformProbeBottomLeftCyan))
}
if clipProbe || clipOutProbe {
    probeChecks.append(("probeTopLeftCyan", probeTopLeftCyan, 2000))
}
if clipPathProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, minClipPathProbeRightCyan))
}
if graphicsLayerClipProbe || graphicsLayerRoundClipProbe || graphicsLayerPathClipProbe {
    let cyanThreshold = graphicsLayerShadowProbe ? 30 : 1000
    probeChecks.append(("probeRightCyan", probeRightCyan, cyanThreshold))
    probeChecks.append(("probeRightPurple", probeRightPurple, 1000))
}
if graphicsLayerColorFilterProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, 1000))
}
if graphicsLayerColorMatrixFilterProbe {
    probeChecks.append(("probeRightPurple", probeRightPurple, 1000))
}
if graphicsLayerShadowProbe {
    probeChecks.append(("probeRightShadow", probeRightShadow, 400))
}
if drawPathProbe {
    probeChecks.append(("probeRightOrange", probeRightOrange, 2000))
}
if drawArcProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, 1500))
}
if drawRoundRectProbe {
    probeChecks.append(("probeRightPurple", probeRightPurple, 3000))
}
if imageShaderProbe && invalidImageShaderProbe {
    probeChecks.append(("probeRightPurple", probeRightPurple, minInvalidImageShaderProbeRightPurple))
} else if imageShaderProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, minImageShaderProbeRightCyan))
    probeChecks.append(("probeRightDark", probeRightDark, minImageShaderProbeRightDark))
}
if linearGradientStrokeProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, 800))
    probeChecks.append(("probeRightOrange", probeRightOrange, minLinearGradientStrokeProbeRightOrange))
}
if linearGradientSurfaceProbe {
    probeChecks.append(("probeRightPurple", probeRightPurple, minLinearGradientSurfaceProbeRightPurple))
}
if linearGradientRoundRectSurfaceProbe {
    probeChecks.append(("probeRightPurple", probeRightPurple, 3000))
    probeChecks.append(("probeRightOrange", probeRightOrange, 500))
    probeChecks.append(("probeRightCyan", probeRightCyan, 400))
}
if radialGradientSurfaceProbe {
    probeChecks.append(("probeRightOrange", probeRightOrange, 500))
    probeChecks.append(("probeRightCyan", probeRightCyan, 400))
}
if radialGradientRoundRectSurfaceProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, 400))
    probeChecks.append(("probeRightOrange", probeRightOrange, 10))
}
if sweepGradientRectProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, 200))
    probeChecks.append(("probeRightPurple", probeRightPurple, 200))
}
if sweepGradientRoundRectSurfaceProbe {
    probeChecks.append(("probeRightCyan", probeRightCyan, 200))
    probeChecks.append(("probeRightPurple", probeRightPurple, 500))
}
if linearGradientPathProbe && !gradientPathStrokeProbe {
    probeChecks.append((
        "linearGradientPathProbePixels",
        probeRightPurple + probeRightOrange + probeRightYellow + probeRightCyan,
        minLinearGradientPathProbePixels
    ))
}
if radialGradientPathProbe && !gradientPathStrokeProbe {
    probeChecks.append((
        "radialGradientPathProbePixels",
        probeRightPurple + probeRightOrange + probeRightYellow + probeRightCyan,
        minRadialGradientPathProbePixels
    ))
}
if sweepGradientPathProbe && !gradientPathStrokeProbe {
    probeChecks.append((
        "sweepGradientPathProbePixels",
        probeRightPurple + probeRightOrange + probeRightYellow + probeRightCyan,
        minSweepGradientPathProbePixels
    ))
}
if blendModeProbe {
    probeChecks.append(("blendModeYellow", blendModeYellow, 500))
    probeChecks.append(("blendModeMultiply", blendModeMultiply, 500))
    probeChecks.append(("blendModeScreen", blendModeScreen, 500))
    probeChecks.append(("blendModeOverlay", blendModeOverlay, 500))
    probeChecks.append(("blendModeDarken", blendModeDarken, 500))
    probeChecks.append(("blendModeLighten", blendModeLighten, 500))
    probeChecks.append(("blendModeDifference", blendModeDifference, 500))
    probeChecks.append(("blendModeExclusion", blendModeExclusion, 500))
    probeChecks.append(("blendModeColorDodge", blendModeColorDodge, 500))
    probeChecks.append(("blendModeColorBurn", blendModeColorBurn, 500))
    probeChecks.append(("blendModeHardlight", blendModeHardlight, 500))
    probeChecks.append(("blendModeSoftlight", blendModeSoftlight, 500))
    probeChecks.append(("blendModeHue", blendModeHue, 500))
    probeChecks.append(("blendModeSaturation", blendModeSaturation, 500))
    probeChecks.append(("blendModeColor", blendModeColor, 500))
    probeChecks.append(("blendModeLuminosity", blendModeLuminosity, 500))
}

for (name, count, minimum) in checks where count < minimum {
    fputs("Expected at least \(minimum) \(name) pixels, found \(count)\n", stderr)
    exit(1)
}
if buttonsComponentProbe {
    let maxButtonsBodyIconTileVeryLight =
        Int(ProcessInfo.processInfo.environment["MAX_BUTTONS_BODY_ICON_TILE_VERY_LIGHT"] ?? "") ?? 100
    if buttonsBodyIconTileVeryLight > maxButtonsBodyIconTileVeryLight {
        fputs("Unexpected very-light body icon tile pixels: buttonsBodyIconTileVeryLight=\(buttonsBodyIconTileVeryLight) max=\(maxButtonsBodyIconTileVeryLight) selectedNavBackground=\(buttonsSelectedNavBackground)\n", stderr)
        exit(1)
    }
}
for (name, passed) in textBoxChecks where !passed {
    fputs("Text placement check failed: \(name) topTextBox=\(topTextMinX),\(topTextMinY),\(topTextMaxX),\(topTextMaxY) bottomTextBox=\(bottomTextMinX),\(bottomTextMinY),\(bottomTextMaxX),\(bottomTextMaxY) primaryButtonTextBox=\(primaryButtonTextMinX),\(primaryButtonTextMinY),\(primaryButtonTextMaxX),\(primaryButtonTextMaxY) primaryButtonWhiteText=\(primaryButtonWhiteText) primaryButtonDarkText=\(primaryButtonDarkText)\n", stderr)
    exit(1)
}
for (name, count, minimum) in popupChecks where count < minimum {
    fputs("Expected at least \(minimum) \(name) pixels, found \(count)\n", stderr)
    exit(1)
}
for (name, count, minimum) in menuChecks where count < minimum {
    fputs("Expected at least \(minimum) \(name) pixels, found \(count)\n", stderr)
    exit(1)
}
for (name, count, minimum) in probeChecks where count < minimum {
    fputs("Expected at least \(minimum) \(name) pixels, found \(count)\n", stderr)
    exit(1)
}
SWIFT
