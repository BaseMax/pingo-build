import SwiftUI

private struct LibraryEditorChrome<Item: LibraryEntry>: ViewModifier {
    let kind: LibraryKind
    let store: ItemStore<Item>
    let id: String
    @Binding var draft: Item?

    @Environment(\.dismiss) private var dismiss
    @State private var confirming = false

    func body(content: Content) -> some View {
        content
            .liquidScreen()
            .navigationTitle(kind.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { deleteButton }
            }
            .confirmationDialog("این " + kind.title + " پاک بشه؟", isPresented: $confirming, titleVisibility: .visible) {
                Button("پاکش کن", role: .destructive, action: delete)
                Button("نه، بمونه", role: .cancel) {}
            } message: {
                Text("بعدش دیگه برنمی‌گرده.")
            }
            .onChange(of: draft) { _, value in write(value) }
            .reloadsOnActive { load() }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            Haptics.warning()
            confirming = true
        } label: {
            Image(systemName: "trash")
        }
        .tint(Color.red)
        .accessibilityLabel("پاک کردن")
    }

    private func load() {
        guard let stored = store.item(id) else {
            dismiss()
            return
        }
        if draft != stored {
            draft = stored
        }
    }

    private func write(_ value: Item?) {
        guard let value, store.item(id) != value else { return }
        store.update(id) { $0 = value }
    }

    private func delete() {
        draft?.cleanUp()
        store.remove(id)
        dismiss()
    }
}

extension View {
    func libraryEditor<Item: LibraryEntry>(
        kind: LibraryKind,
        store: ItemStore<Item>,
        id: String,
        draft: Binding<Item?>
    ) -> some View {
        modifier(LibraryEditorChrome(kind: kind, store: store, id: id, draft: draft))
    }
}
