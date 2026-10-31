import SwiftUI

struct DraftStoreSync<Item: Codable & Identifiable & Hashable>: ViewModifier where Item.ID == String {
    let store: ItemStore<Item>
    @Binding var draft: Item
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .reloadsOnActive { pull() }
            .onReceive(NotificationCenter.default.publisher(for: .pingoStoreChanged)) { _ in
                pull()
            }
            .onChange(of: draft) { _, latest in
                push(latest)
            }
    }

    private func pull() {
        guard let fresh = store.item(draft.id) else {
            dismiss()
            return
        }
        if fresh != draft {
            draft = fresh
        }
    }

    private func push(_ latest: Item) {
        guard let stored = store.item(latest.id), stored != latest else { return }
        store.update(latest.id) { $0 = latest }
    }
}

struct DeleteItemToolbar: ViewModifier {
    let message: String
    let onDelete: () -> Void
    @State private var asking = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarIconButton(symbol: "trash") {
                        asking = true
                    }
                    .accessibilityLabel("حذف")
                }
            }
            .confirmationDialog("این مورد حذف بشه؟", isPresented: $asking, titleVisibility: .visible) {
                Button("حذف", role: .destructive) { confirm() }
                Button("بیخیال", role: .cancel) {}
            } message: {
                Text(message)
            }
    }

    private func confirm() {
        Haptics.warning()
        onDelete()
    }
}

extension View {
    func syncsDraft<Item: Codable & Identifiable & Hashable>(_ draft: Binding<Item>, with store: ItemStore<Item>) -> some View where Item.ID == String {
        modifier(DraftStoreSync(store: store, draft: draft))
    }

    func deletesItem(message: String, perform: @escaping () -> Void) -> some View {
        modifier(DeleteItemToolbar(message: message, onDelete: perform))
    }
}
