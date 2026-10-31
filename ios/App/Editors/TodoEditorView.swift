import SwiftUI

struct TodoEditorView: View {
    private let id: String
    @State private var draft: TodoList?
    @State private var editMode = EditMode.inactive
    @State private var confetti = 0

    init(id: String) {
        self.id = id
        _draft = State(initialValue: Store.todos.item(id))
    }

    private var isComplete: Bool {
        guard let draft else { return false }
        return !draft.items.isEmpty && draft.remaining == 0
    }

    var body: some View {
        content
            .overlay(alignment: .bottom) { ConfettiBurst(trigger: confetti) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LibraryEditButton(editMode: $editMode)
                }
            }
            .libraryEditor(kind: .todo, store: Store.todos, id: id, draft: $draft)
            .onChange(of: isComplete) { old, new in
                if new && !old { celebrate() }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let list = Binding($draft) {
            TodoEditorList(id: id, list: list)
                .environment(\.editMode, $editMode)
        }
    }

    private func celebrate() {
        confetti += 1
        Haptics.success()
    }
}
