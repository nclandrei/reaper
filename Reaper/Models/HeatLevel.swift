import SwiftUI

enum HeatLevel: Int, Comparable {
    case cold
    case cool
    case warm
    case hot
    case critical

    static func < (lhs: HeatLevel, rhs: HeatLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static func forProcess(cpu: Double, memory: UInt64) -> HeatLevel {
        let memGB = Double(memory) / 1_073_741_824
        if cpu > 30 || memGB > 2 { return .critical }
        if cpu > 20 || memGB > 1 { return .hot }
        if cpu > 10 || memGB > 0.5 { return .warm }
        if cpu > 3 || memGB > 0.2 { return .cool }
        return .cold
    }

    var color: Color {
        switch self {
        case .cold:     Color(red: 0.05, green: 0.16, blue: 0.28)
        case .cool:     Color(red: 0.16, green: 0.50, blue: 0.73)
        case .warm:     Color(red: 0.77, green: 0.63, blue: 0.00)
        case .hot:      Color(red: 0.90, green: 0.49, blue: 0.13)
        case .critical: Color(red: 0.90, green: 0.22, blue: 0.27)
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .cold:
            [Color(red: 0.08, green: 0.26, blue: 0.38),
             Color(red: 0.05, green: 0.16, blue: 0.28),
             Color(red: 0.04, green: 0.12, blue: 0.21)]
        case .cool:
            [Color(red: 0.14, green: 0.44, blue: 0.64),
             Color(red: 0.10, green: 0.32, blue: 0.46),
             Color(red: 0.07, green: 0.23, blue: 0.37)]
        case .warm:
            [Color(red: 0.77, green: 0.63, blue: 0.00),
             Color(red: 0.72, green: 0.53, blue: 0.04),
             Color(red: 0.63, green: 0.44, blue: 0.00)]
        case .hot:
            [Color(red: 0.90, green: 0.49, blue: 0.13),
             Color(red: 0.83, green: 0.33, blue: 0.00),
             Color(red: 0.75, green: 0.22, blue: 0.15)]
        case .critical:
            [Color(red: 0.90, green: 0.22, blue: 0.27),
             Color(red: 0.75, green: 0.22, blue: 0.17),
             Color(red: 0.66, green: 0.20, blue: 0.15)]
        }
    }

    var glowColor: Color {
        switch self {
        case .cold, .cool: .clear
        case .warm:        Color(red: 0.77, green: 0.63, blue: 0.00).opacity(0.15)
        case .hot:         Color(red: 0.90, green: 0.49, blue: 0.13).opacity(0.2)
        case .critical:    Color(red: 1.0, green: 0.09, blue: 0.27).opacity(0.25)
        }
    }

    var glowRadius: CGFloat {
        switch self {
        case .cold, .cool: 0
        case .warm:        4
        case .hot:         8
        case .critical:    12
        }
    }
}
