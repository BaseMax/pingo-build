import SwiftUI

struct LibrarySection<Item: LibraryEntry>: View {
    let kind: LibraryKind
    let live: LiveItems<Item>

    @Environment(AppRouter.self) private var router

    var body: some View {
        if !live.items.isEmpty {
            LibraryHeaderRow(kind: kind, count: live.items.count)
            ForEach(live.items) { item in
                LibraryItemRow(
                    item: item,
                    kind: kind,
                    delay: delay(for: item),
                    onOpen: { open(item) },
                    onDuplicate: { duplicate(item) },
                    onDelete: { remove(item) }
                )
            }
            .onMove { source, destination in
                withAnimation(.liquid) { live.move(from: source, to: destination) }
            }
        }
    }

    private func delay(for item: Item) -> Double {
        let index = live.items.firstIndex { $0.id == item.id } ?? 0
        return Double(min(index, 6)) * 0.05
    }

    private func open(_ item: Item) {
        Haptics.selection()
        router.libraryPath.append(ItemRoute(kind: kind, id: item.id))
    }

    private func duplicate(_ item: Item) {
        Haptics.success()
        withAnimation(.liquid) { live.add(item.duplicated()) }
    }

    private func remove(_ item: Item) {
        Haptics.warning()
        item.cleanUp()
        withAnimation(.liquid) { live.remove(item.id) }
    }
}

struct LibraryHeaderRow: View {
    let kind: LibraryKind
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            SectionTitle(kind.plural, symbol: kind.symbol)
            Text(Persian.number(count))
                .dasto(13)
                .foregroundStyle(Color.secondary)
                .contentTransition(.numericText())
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.primary.opacity(0.07), in: Capsule())
        }
        .animation(.liquid, value: count)
        .reveal()
        .libraryRow(top: 14, bottom: 2)
    }
}
