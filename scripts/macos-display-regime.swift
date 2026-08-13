import AppKit
import CoreGraphics
import Foundation

let display = CGMainDisplayID()
guard let mode = CGDisplayCopyDisplayMode(display) else {
    fputs("unable to read the main display mode\n", stderr)
    exit(1)
}

print("display_id=\(display)")
print("mode_width=\(mode.width)")
print("mode_height=\(mode.height)")
print("pixel_width=\(mode.pixelWidth)")
print("pixel_height=\(mode.pixelHeight)")
print(String(format: "refresh_hz=%.3f", mode.refreshRate))
print("io_flags=\(mode.ioFlags)")

if let screen = NSScreen.screens.first(where: {
    ($0.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value == display
}) {
    print(String(format: "backing_scale=%.3f", screen.backingScaleFactor))
    print(String(format: "logical_width=%.3f", screen.frame.width))
    print(String(format: "logical_height=%.3f", screen.frame.height))
} else {
    print("backing_scale=unknown")
    print("logical_width=unknown")
    print("logical_height=unknown")
}
