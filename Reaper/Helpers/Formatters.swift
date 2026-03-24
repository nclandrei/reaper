import Foundation

enum Formatters {
    static func memory(_ bytes: UInt64) -> String {
        let mb = Double(bytes) / 1_048_576
        if mb >= 1024 {
            return String(format: "%.1f GB", mb / 1024)
        }
        return String(format: "%.0f MB", mb)
    }

    static func cpu(_ percent: Double) -> String {
        if percent < 10 {
            return String(format: "%.1f%%", percent)
        }
        return String(format: "%.0f%%", percent)
    }

    static func memoryFraction(used: UInt64, total: UInt64) -> String {
        let usedGB = Double(used) / 1_073_741_824
        let totalGB = Double(total) / 1_073_741_824
        return String(format: "%.1f/%.0f GB", usedGB, totalGB)
    }

    static func memoryShort(used: UInt64, total: UInt64) -> String {
        let usedGB = Double(used) / 1_073_741_824
        let totalGB = Double(total) / 1_073_741_824
        return String(format: "%.0f/%.0fG", usedGB, totalGB)
    }
}
