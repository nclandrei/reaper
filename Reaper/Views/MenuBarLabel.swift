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

    private var fillPercent: Double {
        switch metric {
        case .cpu:
            return min(1.0, max(0.0, stats.totalCPU / 100.0))
        case .memory:
            guard stats.totalMemory > 0 else { return 0 }
            return min(1.0, Double(stats.usedMemory) / Double(stats.totalMemory))
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(nsImage: Self.bar(fill: fillPercent))

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

    static func bar(fill: Double) -> NSImage {
        let w: CGFloat = 22
        let h: CGFloat = 10
        let r: CGFloat = 2
        let s: CGFloat = 2 // Retina

        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil, width: Int(w * s), height: Int(h * s),
            bitsPerComponent: 8, bytesPerRow: 0, space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ), let cgAfterDraw = {
            ctx.scaleBy(x: s, y: s)

            // Background track
            ctx.setFillColor(CGColor(gray: 1, alpha: 0.25))
            ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: h),
                               cornerWidth: r, cornerHeight: r, transform: nil))
            ctx.fillPath()

            // Fill
            let fw = max(r * 2, w * fill)
            ctx.setFillColor(CGColor(gray: 1, alpha: 1.0))
            ctx.addPath(CGPath(roundedRect: CGRect(x: 0, y: 0, width: fw, height: h),
                               cornerWidth: r, cornerHeight: r, transform: nil))
            ctx.fillPath()

            return ctx.makeImage()
        }() else {
            let fb = NSImage(size: .zero)
            fb.isTemplate = true
            return fb
        }

        let img = NSImage(cgImage: cgAfterDraw, size: NSSize(width: w, height: h))
        img.isTemplate = true
        return img
    }
}
