import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.animates) private var parentAnimates

    private var selection: Binding<AppTab> {
        Binding(get: { router.tab }, set: { router.tab = $0 })
    }

    var body: some View {
        ZStack {
            ForEach(AppTab.allCases) { tab in
                page(tab)
            }
            LiquidDock(selection: selection)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .zIndex(2)
            LibraryAddLayer()
                .zIndex(3)
        }
    }

    private func page(_ tab: AppTab) -> some View {
        let isActive = router.tab == tab
        return root(tab)
            .modifier(BlurFade(hidden: !isActive))
            .allowsHitTesting(isActive)
            .accessibilityHidden(!isActive)
            .environment(\.animates, isActive && parentAnimates)
            .animation(.liquid, value: isActive)
            .zIndex(isActive ? 1 : 0)
    }

    @ViewBuilder
    private func root(_ tab: AppTab) -> some View {
        switch tab {
        case .gallery: GalleryView()
        case .library: LibraryView()
        case .settings: SettingsView()
        }
    }
}
