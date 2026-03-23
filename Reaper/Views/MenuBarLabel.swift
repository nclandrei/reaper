import SwiftUI

struct MenuBarLabel: View {
    let cpuUsage: Double

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 11))
            Text("\(Int(cpuUsage))%")
                .font(.system(size: 11, design: .monospaced))
                .monospacedDigit()
        }
    }
}
