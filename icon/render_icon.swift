#!/usr/bin/env swift
import AppKit
import CoreText

let size = 1024
let cgSize = CGSize(width: size, height: size)
let cornerRadius: CGFloat = 220

// Create bitmap context
let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
) else {
    fputs("Failed to create context\n", stderr)
    exit(1)
}

let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
NSGraphicsContext.current = nsCtx

// -- Background rounded rect with gradient --
let bgPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: cgSize), xRadius: cornerRadius, yRadius: cornerRadius)
bgPath.addClip()

// Dark gradient background
let gradient = NSGradient(
    colors: [
        NSColor(red: 0.11, green: 0.11, blue: 0.19, alpha: 1.0),
        NSColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1.0)
    ],
    atLocations: [0.0, 1.0],
    colorSpace: .deviceRGB
)!
gradient.draw(in: NSRect(origin: .zero, size: cgSize), angle: -45)

// -- Radial glow --
ctx.saveGState()
let glowColors = [
    NSColor(red: 0.86, green: 0.16, blue: 0.24, alpha: 0.2).cgColor,
    NSColor(red: 0.86, green: 0.16, blue: 0.24, alpha: 0.0).cgColor
]
let glowGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors as CFArray, locations: [0.0, 1.0])!
ctx.drawRadialGradient(
    glowGradient,
    startCenter: CGPoint(x: 360, y: 680),
    startRadius: 0,
    endCenter: CGPoint(x: 360, y: 680),
    endRadius: 400,
    options: []
)
ctx.restoreGState()

// -- Render skull emoji --
let emoji = "💀"
let fontSize: CGFloat = 560
let font = CTFontCreateWithName("Apple Color Emoji" as CFString, fontSize, nil)

let attrString = NSAttributedString(string: emoji, attributes: [
    .font: font
])

let line = CTLineCreateWithAttributedString(attrString)
let bounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)

// Center the emoji
let x = (CGFloat(size) - bounds.width) / 2.0 - bounds.origin.x
let y = (CGFloat(size) - bounds.height) / 2.0 - bounds.origin.y - 10

ctx.saveGState()

// Shadow for depth
ctx.setShadow(
    offset: CGSize(width: 0, height: -12),
    blur: 50,
    color: NSColor(red: 0.86, green: 0.16, blue: 0.24, alpha: 0.45).cgColor
)

ctx.textPosition = CGPoint(x: x, y: y)
CTLineDraw(line, ctx)
ctx.restoreGState()

// -- Export PNG --
guard let image = ctx.makeImage() else {
    fputs("Failed to create image\n", stderr)
    exit(1)
}

let bitmapRep = NSBitmapImageRep(cgImage: image)
guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
    fputs("Failed to create PNG\n", stderr)
    exit(1)
}

let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "reaper-icon-1024.png"

try! pngData.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath) (\(size)x\(size))")
