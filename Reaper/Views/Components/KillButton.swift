import SwiftUI

struct KillButton: View {
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 18))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isHovering ? .red : .red.opacity(0.7))
        }
        .buttonStyle(.plain)
        .frame(width: 28, height: 28)
        .onHover { isHovering = $0 }
        .help("Quit process")
    }
}
