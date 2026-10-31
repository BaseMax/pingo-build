import SwiftUI

struct CountdownEditorView: View {
    private let id: String
    @State private var draft: CountdownItem?

    init(id: String) {
        self.id = id
        _draft = State(initialValue: Store.countdowns.item(id))
    }

    var body: some View {
        ScrollView {
            if let item = Binding($draft) {
                CountdownEditorForm(id: id, item: item)
            }
        }
        .libraryEditor(kind: .countdown, store: Store.countdowns, id: id, draft: $draft)
    }
}
