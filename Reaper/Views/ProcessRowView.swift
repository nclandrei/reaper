import SwiftUI

struct ProcessRowView: View {
    let process: ProcessInfo
    let isHelper: Bool
    let onKill: () -> Void
    let onForceKill: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            if let icon = process.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 18, height: 18)
            } else {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
                    .frame(width: 18, height: 18)
                    .foregroundStyle(.quaternary)
            }

            // Name
            Text(process.name)
                .font(.system(size: 12))
                .foregroundStyle(isHelper ? .secondary : .primary)
                .lineLimit(1)

            Spacer()

            // Stats
            Text(Formatters.cpu(process.cpu))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 50, alignment: .trailing)

            Text(Formatters.memory(process.memory))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.tertiary)
                .frame(width: 60, alignment: .trailing)

            // Kill button
            if isHovering {
                KillButton(action: onKill)
            } else {
                Color.clear.frame(width: 28, height: 28)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovering ? .white.opacity(0.04) : .clear)
        )
        .contextMenu {
            Button("Quit") { onKill() }
            Button("Force Quit") { onForceKill() }
            Divider()
            Button("Copy PID (\(process.pid))") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString("\(process.pid)", forType: .string)
            }
        }
    }
}
