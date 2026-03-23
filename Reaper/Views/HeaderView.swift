import SwiftUI

struct HeaderView: View {
    @Binding var searchText: String
    @Binding var sortOrder: SortOrder
    let systemStats: SystemStats

    var body: some View {
        VStack(spacing: 10) {
            // System stats bar
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "cpu")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.blue)
                    Text(Formatters.cpu(systemStats.totalCPU))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .monospacedDigit()
                }

                HStack(spacing: 6) {
                    Image(systemName: "memorychip")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.purple)
                    Text(Formatters.memoryFraction(used: systemStats.usedMemory, total: systemStats.totalMemory))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .monospacedDigit()
                }

                Spacer()
            }

            // Search + Sort
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: 13))
                    TextField("Search apps...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Pill sort buttons
                HStack(spacing: 2) {
                    ForEach(SortOrder.allCases) { order in
                        Button {
                            sortOrder = order
                        } label: {
                            Text(order.rawValue)
                                .font(.system(size: 11, weight: sortOrder == order ? .semibold : .regular))
                                .foregroundStyle(sortOrder == order ? .white : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(sortOrder == order ? .white.opacity(0.15) : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
                .background(.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }
}
