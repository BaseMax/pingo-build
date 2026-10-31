import SwiftUI

struct LibraryItemRow<Item: LibraryEntry>: View {
    let item: Item
    let kind: LibraryKind
    let delay: Double
    let onOpen: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    @Environment(\.editMode) private var editMode

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    var body: some View {
        Button(action: onOpen) { row }
            .buttonStyle(Pressable())
            .disabled(isEditing)
            .reveal(delay)
            .libraryRow()
            .contextMenu { menu }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) { deleteButton }
            .swipeActions(edge: .leading) { duplicateButton.tint(Color.ocean) }
    }

    private var row: some View {
        LiquidRow(title: item.entryTitle, subtitle: item.entrySubtitle) {
            LibrarySymbolTile(
                symbol: item.entrySymbol ?? kind.symbol,
                theme: item.entryTheme ?? Store.theme(for: kind.widget)
            )
        } trailing: {
            Image(systemName: "chevron.forward")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.secondary.opacity(0.6))
        }
    }

    @ViewBuilder
    private var menu: some View {
        duplicateButton
        Button(role: .destructive, action: onDelete) {
            Label("پاکش کن", systemImage: "trash")
        }
    }

    private var duplicateButton: some View {
        Button(action: onDuplicate) {
            Label("یه کپی بساز", systemImage: "plus.square.on.square")
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive, action: onDelete) {
            Label("پاکش کن", systemImage: "trash")
        }
    }
}
