import SwiftUI

struct ItemEditorView: View {
    let route: ItemRoute

    var body: some View {
        switch route.kind {
        case .note: NoteEditorView(id: route.id)
        case .countdown: CountdownEditorView(id: route.id)
        case .habit: HabitEditorView(id: route.id)
        case .todo: TodoEditorView(id: route.id)
        case .counter: CounterEditorView(id: route.id)
        case .album: AlbumEditorView(id: route.id)
        }
    }
}
