import SwiftUI
import AppKit

// MARK: - Renderer

enum MenuBarRenderer {
    private static let scale: CGFloat = 2

    private static func makeContext(w: CGFloat, h: CGFloat) -> (CGContext, CGFloat, CGFloat)? {
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil, width: Int(w * scale), height: Int(h * scale),
            bitsPerComponent: 8, bytesPerRow: 0, space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.scaleBy(x: scale, y: scale)
        return (ctx, w, h)
    }

    private static func finish(_ ctx: CGContext, w: CGFloat, h: CGFloat) -> NSImage {
        guard let cg = ctx.makeImage() else {
            let fb = NSImage(size: .zero); fb.isTemplate = true; return fb
        }
        let img = NSImage(cgImage: cg, size: NSSize(width: w, height: h))
        img.isTemplate = true
        return img
    }

    private static let dim: CGFloat = 0.25
    private static let bright: CGFloat = 1.0

    // Skull with colored eyes
    static func skull(fill: Double) -> NSImage {
        let size: CGFloat = 18
        guard let (ctx, w, h) = makeContext(w: size, h: size) else { return NSImage() }

        // Eye color: green (<40%), yellow (40-70%), red (>70%)
        let eyeColor: CGColor
        if fill > 0.7 {
            eyeColor = CGColor(red: 0.90, green: 0.22, blue: 0.27, alpha: 1.0)
        } else if fill > 0.4 {
            eyeColor = CGColor(red: 0.90, green: 0.75, blue: 0.10, alpha: 1.0)
        } else {
            eyeColor = CGColor(red: 0.30, green: 0.78, blue: 0.40, alpha: 1.0)
        }

        // Skull outline - cranium (top rounded part)
        let craniumRect = CGRect(x: 2, y: 5, width: 14, height: 11)
        ctx.setFillColor(CGColor(gray: 1, alpha: 0.9))
        ctx.addEllipse(in: craniumRect)
        ctx.fillPath()

        // Jaw (narrower bottom rectangle with rounded bottom)
        let jawPath = CGMutablePath()
        jawPath.addRoundedRect(in: CGRect(x: 4.5, y: 1, width: 9, height: 6), cornerWidth: 2, cornerHeight: 2)
        ctx.addPath(jawPath)
        ctx.fillPath()

        // Left eye socket
        ctx.setFillColor(eyeColor)
        ctx.addEllipse(in: CGRect(x: 5, y: 9, width: 3.5, height: 3.5))
        ctx.fillPath()

        // Right eye socket
        ctx.addEllipse(in: CGRect(x: 9.5, y: 9, width: 3.5, height: 3.5))
        ctx.fillPath()

        // Nose (small inverted triangle)
        ctx.setFillColor(CGColor(srgbRed: 0.12, green: 0.12, blue: 0.20, alpha: 1.0))
        ctx.move(to: CGPoint(x: 8, y: 7))
        ctx.addLine(to: CGPoint(x: 9.5, y: 7))
        ctx.addLine(to: CGPoint(x: 8.75, y: 8.2))
        ctx.closePath()
        ctx.fillPath()

        // Teeth lines
        ctx.setStrokeColor(CGColor(srgbRed: 0.12, green: 0.12, blue: 0.20, alpha: 0.6))
        ctx.setLineWidth(0.6)
        for x in stride(from: 6.0, through: 12.0, by: 1.5) {
            ctx.move(to: CGPoint(x: x, y: 1.5))
            ctx.addLine(to: CGPoint(x: x, y: 5.5))
        }
        ctx.strokePath()

        // Eye glow for red/yellow states
        if fill > 0.4 {
            ctx.setFillColor(CGColor(
                red: fill > 0.7 ? 0.90 : 0.90,
                green: fill > 0.7 ? 0.22 : 0.75,
                blue: fill > 0.7 ? 0.27 : 0.10,
                alpha: 0.3
            ))
            ctx.addEllipse(in: CGRect(x: 3.5, y: 7.5, width: 6, height: 6))
            ctx.fillPath()
            ctx.addEllipse(in: CGRect(x: 8, y: 7.5, width: 6, height: 6))
            ctx.fillPath()
        }

        guard let cg = ctx.makeImage() else { return NSImage() }
        let img = NSImage(cgImage: cg, size: NSSize(width: w, height: h))
        img.isTemplate = false
        return img
    }

    // A: Pill Bar
    static func pillBar(fill: Double) -> NSImage {
        let w: CGFloat = 24, h: CGFloat = 10, r: CGFloat = 5
        guard let (ctx, w, h) = makeContext(w: w, h: h) else { return NSImage() }

        ctx.setFillColor(CGColor(gray: 1, alpha: dim))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: h), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()

        let fw = max(r * 2, w * fill)
        ctx.setFillColor(CGColor(gray: 1, alpha: bright))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: fw, height: h), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()

        return finish(ctx, w: w, h: h)
    }

    // B: Segments
    static func segments(fill: Double) -> NSImage {
        let count = 8, segW: CGFloat = 3, gap: CGFloat = 1.5, h: CGFloat = 10
        let w = CGFloat(count) * (segW + gap) - gap
        guard let (ctx, w, h) = makeContext(w: w, h: h) else { return NSImage() }

        let filledCount = Int(round(fill * Double(count)))
        for i in 0..<count {
            let x = CGFloat(i) * (segW + gap)
            let alpha: CGFloat = i < filledCount ? bright : dim
            ctx.setFillColor(CGColor(gray: 1, alpha: alpha))
            ctx.addPath(CGPath(roundedRect: CGRect(x: x, y: 0, width: segW, height: h), cornerWidth: 1, cornerHeight: 1, transform: nil))
            ctx.fillPath()
        }

        return finish(ctx, w: w, h: h)
    }

    // C: Thin Line
    static func thinLine(fill: Double) -> NSImage {
        let w: CGFloat = 32, h: CGFloat = 4, r: CGFloat = 2
        guard let (ctx, w, h) = makeContext(w: w, h: h) else { return NSImage() }

        ctx.setFillColor(CGColor(gray: 1, alpha: dim))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: h), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()

        let fw = max(r * 2, w * fill)
        ctx.setFillColor(CGColor(gray: 1, alpha: bright))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: fw, height: h), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()

        return finish(ctx, w: w, h: h)
    }

    // D: Ring Gauge
    static func ringGauge(fill: Double) -> NSImage {
        let size: CGFloat = 14, lw: CGFloat = 2.5
        guard let (ctx, w, h) = makeContext(w: size, h: size) else { return NSImage() }

        let center = CGPoint(x: size / 2, y: size / 2)
        let radius = (size - lw) / 2

        // Track
        ctx.setStrokeColor(CGColor(gray: 1, alpha: dim))
        ctx.setLineWidth(lw)
        ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        ctx.strokePath()

        // Fill arc (starts from top, goes clockwise)
        if fill > 0.01 {
            ctx.setStrokeColor(CGColor(gray: 1, alpha: bright))
            ctx.setLineWidth(lw)
            ctx.setLineCap(.round)
            let startAngle = CGFloat.pi / 2
            let endAngle = startAngle - CGFloat(fill) * .pi * 2
            ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            ctx.strokePath()
        }

        return finish(ctx, w: w, h: h)
    }

    // E: Battery
    static func battery(fill: Double) -> NSImage {
        let w: CGFloat = 26, h: CGFloat = 11, r: CGFloat = 2.5
        let totalW = w + 4 // extra for nub
        guard let (ctx, tw, th) = makeContext(w: totalW, h: h) else { return NSImage() }

        let bw: CGFloat = 1.5
        // Outline
        ctx.setStrokeColor(CGColor(gray: 1, alpha: 0.6))
        ctx.setLineWidth(bw)
        ctx.addPath(CGPath(roundedRect: CGRect(x: bw/2, y: bw/2, width: w - bw, height: h - bw), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.strokePath()

        // Nub
        ctx.setFillColor(CGColor(gray: 1, alpha: 0.5))
        ctx.fill(CGRect(x: w, y: 3, width: 2, height: 5))

        // Fill inside
        let inset: CGFloat = 2.5
        let innerW = w - inset * 2
        let innerH = h - inset * 2
        let fw = max(2, innerW * fill)
        ctx.setFillColor(CGColor(gray: 1, alpha: bright))
        ctx.addPath(CGPath(roundedRect: CGRect(x: inset, y: inset, width: fw, height: innerH), cornerWidth: 1, cornerHeight: 1, transform: nil))
        ctx.fillPath()

        return finish(ctx, w: tw, h: th)
    }

    // F: Dots
    static func dots(fill: Double) -> NSImage {
        let count = 8, dotR: CGFloat = 2, gap: CGFloat = 2.5
        let h: CGFloat = dotR * 2
        let w = CGFloat(count) * (dotR * 2 + gap) - gap
        guard let (ctx, w, h) = makeContext(w: w, h: h) else { return NSImage() }

        let filledCount = Int(round(fill * Double(count)))
        for i in 0..<count {
            let cx = CGFloat(i) * (dotR * 2 + gap) + dotR
            let alpha: CGFloat = i < filledCount ? bright : dim
            ctx.setFillColor(CGColor(gray: 1, alpha: alpha))
            ctx.addEllipse(in: CGRect(x: cx - dotR, y: 0, width: dotR * 2, height: dotR * 2))
            ctx.fillPath()
        }

        return finish(ctx, w: w, h: h)
    }

    // G: Mini Bars (history)
    static func miniBars(samples: [Double]) -> NSImage {
        let count = 8, barW: CGFloat = 3, gap: CGFloat = 1.5, h: CGFloat = 14
        let w = CGFloat(count) * (barW + gap) - gap
        guard let (ctx, w, h) = makeContext(w: w, h: h) else { return NSImage() }

        let display: [Double]
        if samples.count >= count {
            display = Array(samples.suffix(count))
        } else {
            display = Array(repeating: 0, count: count - samples.count) + samples
        }

        for (i, val) in display.enumerated() {
            let norm = min(1.0, max(0.0, val / 100.0))
            let x = CGFloat(i) * (barW + gap)

            // Ghost track
            ctx.setFillColor(CGColor(gray: 1, alpha: dim * 0.5))
            ctx.fill(CGRect(x: x, y: 0, width: barW, height: h))

            // Filled portion
            let barH = max(1.5, norm * h)
            ctx.setFillColor(CGColor(gray: 1, alpha: bright))
            ctx.fill(CGRect(x: x, y: 0, width: barW, height: barH))
        }

        return finish(ctx, w: w, h: h)
    }

    // H: Dual Stack
    static func dualStack(cpu: Double, mem: Double) -> NSImage {
        let w: CGFloat = 28, h: CGFloat = 12, barH: CGFloat = 4, gap: CGFloat = 3, r: CGFloat = 2
        guard let (ctx, w, h) = makeContext(w: w, h: h) else { return NSImage() }

        // Top bar (CPU)
        let topY = gap + barH
        ctx.setFillColor(CGColor(gray: 1, alpha: dim))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: topY, width: w, height: barH), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()
        ctx.setFillColor(CGColor(gray: 1, alpha: bright))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: topY, width: max(r*2, w * cpu), height: barH), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()

        // Bottom bar (Memory)
        ctx.setFillColor(CGColor(gray: 1, alpha: dim))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: barH), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()
        ctx.setFillColor(CGColor(gray: 1, alpha: bright))
        ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: max(r*2, w * mem), height: barH), cornerWidth: r, cornerHeight: r, transform: nil))
        ctx.fillPath()

        return finish(ctx, w: w, h: h)
    }
}
