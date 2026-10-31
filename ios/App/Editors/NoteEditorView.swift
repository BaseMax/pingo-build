import SwiftUI

struct NoteEditorView: View {
    private let id: String
    @State private var draft: NoteItem?

    init(id: String) {
        self.id = id
        _draft = State(initialValue: Store.notes.item(id))
    }

    var body: some View {
        ScrollView {
            if let item = Binding($draft) {
                NoteEditorForm(id: id, item: item)
            }
        }
        .libraryEditor(kind: .note, store: Store.notes, id: id, draft: $draft)
    }
}
