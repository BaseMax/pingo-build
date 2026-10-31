import SwiftUI

struct LibraryAddLayer: View {
    @Environment(AppRouter.self) private var router

    private var isVisible: Bool {
        router.tab == .library && router.libraryPath.isEmpty
    }

    private var isOpen: Binding<Bool> {
        Binding(get: { router.addMenuOpen }, set: { router.addMenuOpen = $0 })
    }

    var body: some View {
        ZStack {
            if router.addMenuOpen {
                FloatingScrim { router.addMenuOpen = false }
            }
            if isVisible {
                FloatingAddMenu(actions: actions, isOpen: isOpen)
                    .transition(.blurFade)
            }
        }
        .animation(.liquid, value: router.addMenuOpen)
        .animation(.liquid, value: isVisible)
        .onChange(of: isVisible) { _, visible in
            if !visible { router.addMenuOpen = false }
        }
    }

    private var actions: [FloatingAction] {
        LibraryKind.allCases.map { kind in
            FloatingAction(id: kind.rawValue, title: kind.title, symbol: kind.symbol, tint: kind.libraryTint) {
                router.createItem(kind)
            }
        }
    }
}
