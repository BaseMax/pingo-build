import SwiftUI

private struct LibraryEditorChrome<Item: LibraryEntry>: ViewModifier {
    let kind: LibraryKind
    let store: ItemStore<Item>
    let id: String
    @Binding var draft: Item?

    @Environment(\.dismiss) private var dismiss
    @State private var confirming = false
    @State private var synced: Item?

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
            .onReceive(NotificationCenter.default.publisher(for: .pingoStoreChanged)) { _ in
                pull()
            }
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
        adopt(stored)
    }

    private func pull() {
        guard draft == synced else { return }
        load()
    }

    private func adopt(_ stored: Item) {
        synced = stored
        if draft != stored {
            draft = stored
        }
    }

    private func write(_ value: Item?) {
        guard let value else { return }
        synced = value
        guard store.item(id) != value else { return }
        store.update(id) { $0 = value }
    }

    private func delete() {
        synced = nil
        draft?.cleanUp()
        dismiss()
        store.remove(id)
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
