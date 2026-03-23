import SwiftUI

struct UsageBar: View {
    let value: Double
    var color: Color = .blue

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.08))
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: geo.size.width * min(1, max(0, value)))
            }
        }
        .frame(height: 3)
    }
}
