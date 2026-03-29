import SwiftUI

struct ThreatGroupView: View {
    let group: ProcessGroup
    let isExpanded: Bool
    let isSearching: Bool
    let onToggle: () -> Void
    let onKill: (pid_t) -> Void
    let onForceKill: (pid_t) -> Void
    let onKillGroup: () -> Void

    @State private var isHovering = false
    @State private var visibleCount = 10

    private let pageSize = 10

    private var severity: Color {
        if group.totalCPU > 100 || group.totalMemory > 4_294_967_296 {
            return .red
        }
        return .orange
    }

    var body: some View {
        VStack(spacing: 0) {
            // Group header row
            HStack(spacing: 10) {
                if group.helperCount > 0 {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .frame(width: 12)
                } else {
                    Spacer()
                        .frame(width: 12)
                }

                if let icon = group.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "app.fill")
                        .font(.system(size: 22))
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.tertiary)
                }

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(group.name)
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(1)

                        if group.helperCount > 0 {
                            Text("+\(group.helperCount)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.white.opacity(0.08))
                                .clipShape(Capsule())
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text(Formatters.cpu(group.totalCPU))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(group.totalCPU > 50 ? severity : .secondary)

                    Text(Formatters.memory(group.totalMemory))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(group.totalMemory > 2_147_483_648 ? severity : Color.secondary)
                }
                .frame(width: 70, alignment: .trailing)

                // Always-visible kill button for threats
                KillButton {
                    if group.children.count == 1 {
                        onKill(group.children[0].pid)
                    } else {
                        onKillGroup()
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                if isExpanded { visibleCount = pageSize }
                onToggle()
            }
            .onHover { isHovering = $0 }
            .contextMenu {
                Button("Quit") { onKillGroup() }
                Button("Force Quit") {
                    for child in group.children {
                        onForceKill(child.pid)
                    }
                }
                Divider()
                if let main = group.children.first {
                    Button("Copy PID (\(main.pid))") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString("\(main.pid)", forType: .string)
                    }
                }
            }

            // Expanded children
            if (isExpanded || isSearching) && group.helperCount > 0 {
                let helpers = group.children.filter { $0.pid != group.id }
                let visible = Array(helpers.prefix(visibleCount))
                let remaining = helpers.count - visible.count

                VStack(spacing: 0) {
                    ForEach(visible) { process in
                        ProcessRowView(
                            process: process,
                            isHelper: true,
                            onKill: { onKill(process.pid) },
                            onForceKill: { onForceKill(process.pid) }
                        )
                    }

                    if remaining > 0 {
                        Button {
                            withAnimation(.easeOut(duration: 0.15)) {
                                visibleCount += pageSize
                            }
                        } label: {
                            Text("Show \(min(remaining, pageSize)) more (\(remaining) remaining)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(severity.opacity(isHovering ? 0.12 : 0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(severity.opacity(0.2), lineWidth: 1)
        )
    }
}
