import SwiftUI
import AppKit

enum MenuBarMetric: String, CaseIterable, Identifiable {
    case memory = "Memory"
    case cpu = "CPU"

    var id: String { rawValue }
}

struct MenuBarLabel: View {
    let stats: SystemStats
    let metric: MenuBarMetric
    let style: MenuBarStyle
    let cpuHistory: [Double]
    let memoryHistory: [Double]

    private var fillPercent: Double {
        switch metric {
        case .cpu: return min(1.0, max(0.0, stats.totalCPU / 100.0))
        case .memory:
            guard stats.totalMemory > 0 else { return 0 }
            return min(1.0, Double(stats.usedMemory) / Double(stats.totalMemory))
        }
    }

    private var history: [Double] {
        metric == .cpu ? cpuHistory : memoryHistory
    }

    var body: some View {
        HStack(spacing: 7) {
            if style != .textOnly && style != .dualStack {
                Image(nsImage: renderIndicator())
            }

            if style == .dualStack {
                Image(nsImage: MenuBarRenderer.dualStack(
                    cpu: min(1, max(0, stats.totalCPU / 100.0)),
                    mem: stats.totalMemory > 0 ? min(1, Double(stats.usedMemory) / Double(stats.totalMemory)) : 0
                ))
                Text("\(Int(stats.totalCPU))%")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                Text(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .monospacedDigit()
            } else if style == .textOnly {
                switch metric {
                case .cpu:
                    Text("\(Int(stats.totalCPU))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                    Text(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))
                        .font(.system(size: 11, design: .monospaced))
                        .monospacedDigit()
                        .opacity(0.5)
                case .memory:
                    Text(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                    Text("\(Int(stats.totalCPU))%")
                        .font(.system(size: 11, design: .monospaced))
                        .monospacedDigit()
                        .opacity(0.5)
                }
            } else {
                switch metric {
                case .memory:
                    Text(Formatters.memoryShort(used: stats.usedMemory, total: stats.totalMemory))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                case .cpu:
                    Text("\(Int(stats.totalCPU))%")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                }
            }
        }
    }

    private func renderIndicator() -> NSImage {
        let fill = fillPercent
        switch style {
        case .pillBar:    return MenuBarRenderer.pillBar(fill: fill)
        case .segments:   return MenuBarRenderer.segments(fill: fill)
        case .thinLine:   return MenuBarRenderer.thinLine(fill: fill)
        case .ringGauge:  return MenuBarRenderer.ringGauge(fill: fill)
        case .battery:    return MenuBarRenderer.battery(fill: fill)
        case .dots:       return MenuBarRenderer.dots(fill: fill)
        case .miniBars:   return MenuBarRenderer.miniBars(samples: history)
        case .dualStack, .textOnly:
            return NSImage()
        }
    }
}

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
