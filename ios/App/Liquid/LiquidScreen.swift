import SwiftUI

private struct LiquidScreen: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: Layout.dockClearance)
            }
            .background {
                MeshBackdrop().ignoresSafeArea()
            }
    }
}

extension View {
    func liquidScreen() -> some View {
        modifier(LiquidScreen())
    }
}
