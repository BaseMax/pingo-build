import SwiftUI

@MainActor
final class LibraryCollections {
    let notes = LiveItems(Store.notes)
    let countdowns = LiveItems(Store.countdowns)
    let habits = LiveItems(Store.habits)
    let todos = LiveItems(Store.todos)
    let counters = LiveItems(Store.counters)
    let albums = LiveItems(Store.albums)

    func reloadAll() {
        notes.reload()
        countdowns.reload()
        habits.reload()
        todos.reload()
        counters.reload()
        albums.reload()
    }

    func count(of kind: LibraryKind) -> Int {
        switch kind {
        case .note: notes.items.count
        case .countdown: countdowns.items.count
        case .habit: habits.items.count
        case .todo: todos.items.count
        case .counter: counters.items.count
        case .album: albums.items.count
        }
    }

    func isEmpty(showing filter: LibraryKind?) -> Bool {
        let kinds = filter.map { [$0] } ?? LibraryKind.allCases
        return kinds.allSatisfy { count(of: $0) == 0 }
    }

    func create(_ kind: LibraryKind) -> ItemRoute {
        let id = Store.create(kind)
        reloadAll()
        return ItemRoute(kind: kind, id: id)
    }
}
