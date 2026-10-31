import SwiftUI
import Observation

enum AppSheet: Identifiable, Hashable {
    case guide(PingoKind?)

    var id: String {
        switch self {
        case .guide(let kind): "guide-" + (kind?.rawValue ?? "all")
        }
    }
}

@MainActor @Observable
final class AppRouter {
    var tab: AppTab = .gallery
    var galleryPath = NavigationPath()
    var libraryPath = NavigationPath()
    var sheet: AppSheet?
    var libraryFilter: LibraryKind?

    func open(_ route: Route) {
        switch route {
        case .kind(let kind): openKind(kind)
        case .item(let item): openItem(item)
        case .library(let kind): openLibrary(kind)
        case .settings: select(.settings)
        case .guide(let kind): sheet = .guide(kind)
        }
    }

    func handle(_ url: URL) {
        guard let route = Route(url: url) else { return }
        open(route)
    }

    private func openKind(_ kind: PingoKind) {
        select(.gallery)
        galleryPath = NavigationPath([kind])
    }

    private func openItem(_ item: ItemRoute) {
        select(.library)
        libraryPath = NavigationPath([item])
    }

    private func openLibrary(_ kind: LibraryKind?) {
        select(.library)
        libraryFilter = kind
        libraryPath = NavigationPath()
    }

    private func select(_ target: AppTab) {
        guard tab != target else { return }
        withAnimation(.liquid) { tab = target }
    }
}
