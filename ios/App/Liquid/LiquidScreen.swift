import SwiftUI

private struct LiquidScreen: ViewModifier {
    @State private var isTop = true

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: Layout.dockClearance)
            }
            .background {
                MeshBackdrop(isLive: isTop).ignoresSafeArea()
            }
            .onAppear { isTop = true }
            .onDisappear { isTop = false }
    }
}

extension View {
    func liquidScreen() -> some View {
        modifier(LiquidScreen())
    }
}
