import SwiftUI

struct HeatmapGridView: View {
    let groups: [ProcessGroup]
    let onKill: (pid_t) -> Void
    let onForceKill: (pid_t) -> Void
    let onKillGroup: (ProcessGroup) -> Void

    private let gridColumns = 12
    private let gridRows = 8
    private let gap: CGFloat = 4

    private var tiles: [(ProcessGroup, TileLayout)] {
        TileLayout.calculate(groups: groups, gridColumns: gridColumns, gridRows: gridRows)
    }

    var body: some View {
        GeometryReader { geo in
            let cellW = (geo.size.width - gap * CGFloat(gridColumns - 1)) / CGFloat(gridColumns)
            let cellH = (geo.size.height - gap * CGFloat(gridRows - 1)) / CGFloat(gridRows)

            ZStack(alignment: .topLeading) {
                ForEach(Array(tiles.enumerated()), id: \.element.0.id) { _, item in
                    let (group, layout) = item
                    let x = CGFloat(layout.column - 1) * (cellW + gap)
                    let y = CGFloat(layout.row - 1) * (cellH + gap)
                    let w = CGFloat(layout.columnSpan) * cellW + CGFloat(layout.columnSpan - 1) * gap
                    let h = CGFloat(layout.rowSpan) * cellH + CGFloat(layout.rowSpan - 1) * gap

                    HeatmapTileView(
                        group: group,
                        onKill: onKill,
                        onForceKill: onForceKill,
                        onKillGroup: { onKillGroup(group) }
                    )
                    .frame(width: w, height: h)
                    .offset(x: x, y: y)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: tiles.map(\.0.id))
        }
    }
}

// MARK: - Thermal Legend

struct ThermalLegend: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("Cold")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)

            VStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.04, green: 0.12, blue: 0.21),
                                Color(red: 0.05, green: 0.16, blue: 0.28),
                                Color(red: 0.08, green: 0.26, blue: 0.38),
                                Color(red: 0.14, green: 0.44, blue: 0.64),
                                Color(red: 0.18, green: 0.53, blue: 0.76),
                                Color(red: 0.77, green: 0.63, blue: 0.00),
                                Color(red: 0.83, green: 0.63, blue: 0.09),
                                Color(red: 0.90, green: 0.49, blue: 0.13),
                                Color(red: 0.83, green: 0.33, blue: 0.00),
                                Color(red: 0.90, green: 0.22, blue: 0.27),
                                Color(red: 1.0, green: 0.09, blue: 0.27),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)

                HStack {
                    Text("0%")
                    Spacer()
                    Text("Idle")
                    Spacer()
                    Text("Warm")
                    Spacer()
                    Text("Critical")
                    Spacer()
                    Text("100%+")
                }
                .font(.system(size: 7, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.25))
            }

            Text("Hot")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
