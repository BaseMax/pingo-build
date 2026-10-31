import SwiftUI

struct ItemsSection: View {
    let kind: PingoKind

    var body: some View {
        if let library = kind.library {
            list(for: library)
        }
    }

    @ViewBuilder
    private func list(for library: LibraryKind) -> some View {
        switch library {
        case .note: ItemsList(library: library, store: Store.notes, describe: ItemRows.note)
        case .countdown: ItemsList(library: library, store: Store.countdowns, describe: ItemRows.countdown)
        case .habit: ItemsList(library: library, store: Store.habits, describe: ItemRows.habit)
        case .todo: ItemsList(library: library, store: Store.todos, describe: ItemRows.todo)
        case .counter: ItemsList(library: library, store: Store.counters, describe: ItemRows.counter)
        case .album: ItemsList(library: library, store: Store.albums, describe: ItemRows.album)
        }
    }
}

private struct ItemsList<Item: Codable & Identifiable & Hashable>: View where Item.ID == String {
    let library: LibraryKind
    let describe: (Item) -> ItemRowModel

    @Environment(AppRouter.self) private var router
    @State private var live: LiveItems<Item>

    init(library: LibraryKind, store: ItemStore<Item>, describe: @escaping (Item) -> ItemRowModel) {
        self.library = library
        self.describe = describe
        _live = State(initialValue: LiveItems(store))
    }

    var body: some View {
        VStack(spacing: 12) {
            header
            if live.items.isEmpty {
                emptyHint
            } else {
                rows
            }
        }
        .animation(.liquid, value: live.items.map(\.id))
        .reloadsOnActive { live.reload() }
    }

    private var header: some View {
        HStack(spacing: 8) {
            SectionTitle(library.plural, symbol: library.symbol)
            Text(Persian.number(live.items.count))
                .dasto(15)
                .foregroundStyle(Color.secondary)
                .contentTransition(.numericText())
            LiquidIconButton(symbol: "plus") { add() }
                .accessibilityLabel("افزودن " + library.title)
        }
    }

    private var rows: some View {
        VStack(spacing: 10) {
            ForEach(live.items) { item in
                row(describe(item), id: item.id)
                    .transition(.blurFade)
            }
        }
    }

    private var emptyHint: some View {
        Text("هنوز چیزی نداری. با دکمه بالا یکی بساز.")
            .dasto(14)
            .foregroundStyle(Color.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .panel()
            .transition(.blurFade)
    }

    private func row(_ model: ItemRowModel, id: String) -> some View {
        NavigationLink(value: ItemRoute(kind: library, id: id)) {
            LiquidRow(title: model.title, subtitle: model.subtitle) {
                RowSymbolTile(symbol: library.symbol)
            } trailing: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
        }
        .buttonStyle(Pressable())
        .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
    }

    private func add() {
        let id = Store.create(library)
        Haptics.success()
        router.galleryPath.append(ItemRoute(kind: library, id: id))
    }
}
