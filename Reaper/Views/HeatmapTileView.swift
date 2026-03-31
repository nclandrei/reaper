import SwiftUI

struct HeatmapTileView: View {
    let group: ProcessGroup
    let onKill: (pid_t) -> Void
    let onForceKill: (pid_t) -> Void
    let onKillGroup: () -> Void

    @State private var isHovering = false

    private var heat: HeatLevel {
        group.heatLevel
    }

    private var initials: String {
        let name = group.name
        if name.hasPrefix("iT") { return "iT" }
        if name.count <= 2 { return name }
        return String(name.prefix(1))
    }

    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: heat.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Subtle light overlay for depth
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.08), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )

            // Default content: icon (or initial) + name
            VStack(spacing: 2) {
                if let icon = group.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: iconSize, height: iconSize)
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                } else {
                    Text(initials)
                        .font(.system(size: initialFontSize, weight: .heavy))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                }

                Text(group.name)
                    .font(.system(size: nameFontSize, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                    .lineLimit(1)
            }
            .opacity(isHovering ? 0 : 1)
            .animation(.easeOut(duration: 0.15), value: isHovering)

            // Hover overlay
            if isHovering {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.75))
                    .overlay {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                if let icon = group.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .interpolation(.high)
                                        .frame(width: 20, height: 20)
                                }
                                Text(group.name)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            Text("CPU \(Formatters.cpu(group.totalCPU)) · \(Formatters.memory(group.totalMemory))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.6))

                            if let main = group.children.first {
                                Text("PID \(main.pid)")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.4))
                            }

                            Button {
                                onKillGroup()
                            } label: {
                                HStack(spacing: 4) {
                                    Text("☠")
                                        .font(.system(size: 10))
                                    Text("Reap")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color(red: 1.0, green: 0.09, blue: 0.27))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .shadow(color: Color(red: 1.0, green: 0.09, blue: 0.27).opacity(0.4), radius: 4, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.opacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(isHovering ? 0.15 : 0.04), lineWidth: 1)
        )
        .shadow(color: heat.glowColor, radius: heat.glowRadius)
        .scaleEffect(isHovering ? 1.04 : 1.0)
        .zIndex(isHovering ? 10 : 0)
        .animation(.easeOut(duration: 0.2), value: isHovering)
        .contentShape(Rectangle())
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
    }

    // Scale font sizes based on heat level (bigger tiles = bigger fonts)
    private var initialFontSize: CGFloat {
        switch heat {
        case .critical: 36
        case .hot:      30
        case .warm:     22
        case .cool:     18
        case .cold:     14
        }
    }

    private var nameFontSize: CGFloat {
        switch heat {
        case .critical: 12
        case .hot:      11
        case .warm:     10
        case .cool:     9
        case .cold:     8
        }
    }

    // Scale icon size based on heat level (mirrors tile sizing)
    private var iconSize: CGFloat {
        switch heat {
        case .critical: 40
        case .hot:      32
        case .warm:     26
        case .cool:     22
        case .cold:     18
        }
    }
}
