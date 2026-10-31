import Observation
import SwiftUI

@MainActor @Observable
final class LiveItems<Item: Codable & Identifiable & Hashable> where Item.ID == String {
    private(set) var items: [Item]
    @ObservationIgnored private let store: ItemStore<Item>
    @ObservationIgnored private var observer: StoreObserver?

    init(_ store: ItemStore<Item>) {
        self.store = store
        items = store.all
        observer = StoreObserver { [weak self] in self?.reload() }
    }

    func reload() {
        let fresh = store.all
        if fresh != items {
            items = fresh
        }
    }

    func add(_ item: Item) {
        store.add(item)
        reload()
    }

    func update(_ id: String, _ body: (inout Item) -> Void) {
        store.update(id, body)
        reload()
    }

    func remove(_ id: String) {
        store.remove(id)
        reload()
    }

    func move(from source: IndexSet, to destination: Int) {
        store.move(from: source, to: destination)
        reload()
    }
}

private struct ReloadsOnActive: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    let reload: @MainActor () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear { reload() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { reload() }
            }
    }
}

extension View {
    func reloadsOnActive(_ reload: @escaping @MainActor () -> Void) -> some View {
        modifier(ReloadsOnActive(reload: reload))
    }
}
