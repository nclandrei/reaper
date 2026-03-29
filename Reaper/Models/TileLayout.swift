struct TileLayout {
    let column: Int
    let columnSpan: Int
    let row: Int
    let rowSpan: Int

    static func calculate(
        groups: [ProcessGroup],
        gridColumns: Int = 12,
        gridRows: Int = 8
    ) -> [(ProcessGroup, TileLayout)] {
        guard !groups.isEmpty else { return [] }

        let sorted = groups.sorted { $0.threatScore > $1.threatScore }
        let totalScore = sorted.reduce(0) { $0 + max($1.threatScore, 0.01) }

        var result: [(ProcessGroup, TileLayout)] = []

        switch sorted.count {
        case 1:
            result.append((sorted[0], TileLayout(column: 1, columnSpan: gridColumns, row: 1, rowSpan: gridRows)))

        case 2:
            let half = gridColumns / 2
            result.append((sorted[0], TileLayout(column: 1, columnSpan: half, row: 1, rowSpan: gridRows)))
            result.append((sorted[1], TileLayout(column: half + 1, columnSpan: gridColumns - half, row: 1, rowSpan: gridRows)))

        case 3:
            let topRows = (gridRows * 2) / 3
            let bottomRows = gridRows - topRows
            let half = gridColumns / 2
            result.append((sorted[0], TileLayout(column: 1, columnSpan: half, row: 1, rowSpan: topRows)))
            result.append((sorted[1], TileLayout(column: half + 1, columnSpan: gridColumns - half, row: 1, rowSpan: topRows)))
            result.append((sorted[2], TileLayout(column: 1, columnSpan: gridColumns, row: topRows + 1, rowSpan: bottomRows)))

        default:
            // Zone layout: top-half (rows 1..topRows), middle (rows topRows+1..midEnd), bottom remainder
            let topRows = gridRows / 2
            let midRows = (gridRows - topRows) / 2
            let bottomRows = gridRows - topRows - midRows

            // Top zone: first 2 groups split horizontally
            let top0 = sorted[0]
            let top1 = sorted[1]
            let topScore = max(top0.threatScore, 0.01) + max(top1.threatScore, 0.01)
            let col0Span = max(1, min(gridColumns - 1, Int(Double(gridColumns) * max(top0.threatScore, 0.01) / topScore)))
            result.append((top0, TileLayout(column: 1, columnSpan: col0Span, row: 1, rowSpan: topRows)))
            result.append((top1, TileLayout(column: col0Span + 1, columnSpan: gridColumns - col0Span, row: 1, rowSpan: topRows)))

            // Middle zone: next 2 groups split horizontally
            let midStart = topRows + 1
            let midGroups = Array(sorted[2..<min(4, sorted.count)])
            if midGroups.count == 1 {
                result.append((midGroups[0], TileLayout(column: 1, columnSpan: gridColumns, row: midStart, rowSpan: midRows)))
            } else if midGroups.count >= 2 {
                let m0 = midGroups[0]; let m1 = midGroups[1]
                let mScore = max(m0.threatScore, 0.01) + max(m1.threatScore, 0.01)
                let mc0Span = max(1, min(gridColumns - 1, Int(Double(gridColumns) * max(m0.threatScore, 0.01) / mScore)))
                result.append((m0, TileLayout(column: 1, columnSpan: mc0Span, row: midStart, rowSpan: midRows)))
                result.append((m1, TileLayout(column: mc0Span + 1, columnSpan: gridColumns - mc0Span, row: midStart, rowSpan: midRows)))
            }

            // Bottom zone: remaining groups tiled equally
            let remaining = Array(sorted[min(4, sorted.count)...])
            if !remaining.isEmpty {
                let bottomStart = topRows + midRows + 1
                let tileWidth = max(1, gridColumns / remaining.count)
                for (i, group) in remaining.enumerated() {
                    let colStart = i * tileWidth + 1
                    let colSpan = (i == remaining.count - 1) ? (gridColumns - colStart + 1) : tileWidth
                    result.append((group, TileLayout(column: colStart, columnSpan: colSpan, row: bottomStart, rowSpan: bottomRows)))
                }
            }

            // Fill unused mid/bottom area if not enough groups
            _ = totalScore  // suppress unused warning
        }

        return result
    }
}
