import SwiftUI

struct TodoEditorList: View {
    let id: String
    @Binding var list: TodoList

    var body: some View {
        List {
            LibraryPreviewHeader(kind: .todo, id: id)
                .reveal()
                .libraryRow()
            LiquidTextField("اسم فهرست", text: $list.title, symbol: "textformat")
                .reveal(0.07)
                .libraryRow()
            summaryRow
            entries
            TodoAddRow(onAdd: add)
                .libraryRow()
            clearRow
            ThemePickerRow(selection: $list.theme)
                .libraryRow(top: 10, bottom: 5)
        }
        .listStyle(.plain)
    }

    private var summaryRow: some View {
        HStack(spacing: 8) {
            SectionTitle("کارها", symbol: "checklist")
            Text(Persian.number(list.doneCount) + " از " + Persian.number(list.items.count))
                .dasto(13)
                .foregroundStyle(Color.secondary)
                .contentTransition(.numericText())
        }
        .animation(.liquid, value: list.doneCount)
        .animation(.liquid, value: list.items.count)
        .libraryRow(top: 12, bottom: 2)
    }

    private var entries: some View {
        ForEach($list.items) { $entry in
            TodoEntryRow(entry: $entry)
                .libraryRow()
        }
        .onMove { source, destination in
            withAnimation(.liquid) { list.items.move(fromOffsets: source, toOffset: destination) }
        }
        .onDelete { offsets in
            Haptics.warning()
            withAnimation(.liquid) { list.items.remove(atOffsets: offsets) }
        }
    }

    @ViewBuilder
    private var clearRow: some View {
        if list.doneCount > 0 {
            Button(action: clearDone) {
                Label("پاک کردن انجام‌شده‌ها", systemImage: "sparkles")
            }
            .buttonStyle(.liquid)
            .frame(maxWidth: .infinity)
            .transition(.blurFade)
            .libraryRow(top: 8, bottom: 8)
        }
    }

    private func add(_ text: String) {
        withAnimation(.liquid) { list.add(text) }
    }

    private func clearDone() {
        Haptics.soft()
        withAnimation(.liquid) { list.clearDone() }
    }
}
