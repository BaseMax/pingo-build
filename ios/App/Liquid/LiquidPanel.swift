import SwiftUI

struct PanelBackground: View {
    let corner: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
    }

    var body: some View {
        shape
            .fill(Color(.secondarySystemGroupedBackground))
            .overlay {
                shape.strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
            }
    }
}

extension View {
    func panel() -> some View {
        padding(Layout.gutter)
            .background { PanelBackground(corner: Layout.corner) }
    }
}

struct LiquidPanel<Content: View>: View {
    private let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content.panel()
    }
}
