import AppIntents
import SwiftUI

struct TodoRow: View {
    let listID: String
    let entry: TodoEntry
    let metrics: TodoMetrics
    let palette: FacePalette

    var body: some View {
        Button(intent: ToggleTodoIntent(listID: listID, itemID: entry.id)) {
            HStack(spacing: 9) {
                TodoCheckbox(done: entry.done, size: metrics.box, palette: palette)
                label
                Spacer(minLength: 0)
            }
            .frame(height: metrics.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var label: some View {
        Text(entry.text)
            .strikethrough(entry.done)
            .dasto(metrics.textSize)
            .foregroundStyle(entry.done ? palette.soft : palette.ink)
            .lineLimit(1)
    }
}

struct TodoMore: View {
    let count: Int
    let palette: FacePalette

    var body: some View {
        Text("+" + Persian.number(count) + " مورد دیگر")
            .dasto(12)
            .foregroundStyle(palette.soft)
            .lineLimit(1)
    }
}

struct TodoRows: View {
    let list: TodoList
    let metrics: TodoMetrics
    let palette: FacePalette
    var showsMore: Bool = true

    private var shown: [TodoEntry] { list.faceEntries(limit: metrics.limit) }
    private var hidden: Int { list.items.count - shown.count }

    var body: some View {
        VStack(alignment: .leading, spacing: metrics.rowSpacing) {
            ForEach(shown) { entry in
                TodoRow(listID: list.id, entry: entry, metrics: metrics, palette: palette)
            }
            if showsMore && hidden > 0 {
                TodoMore(count: hidden, palette: palette).padding(.top, 2)
            }
        }
    }
}
