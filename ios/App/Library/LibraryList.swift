import SwiftUI

struct LibraryList: View {
    let collections: LibraryCollections
    let filter: LibraryKind?

    var body: some View {
        List {
            section(.note, collections.notes)
            section(.countdown, collections.countdowns)
            section(.habit, collections.habits)
            section(.todo, collections.todos)
            section(.counter, collections.counters)
            section(.album, collections.albums)
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func section<Item: LibraryEntry>(_ kind: LibraryKind, _ live: LiveItems<Item>) -> some View {
        if filter == nil || filter == kind {
            LibrarySection(kind: kind, live: live)
        }
    }
}
