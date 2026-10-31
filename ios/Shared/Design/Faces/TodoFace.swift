import SwiftUI
import WidgetKit

struct TodoFace: View {
    let list: TodoList?
    let size: CardSize
    let theme: Theme

    @Environment(\.widgetRenderingMode) private var mode

    private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }

    var body: some View {
        content.taskFaceFrame(size)
    }

    @ViewBuilder private var content: some View {
        if let list {
            TodoContent(list: list, size: size, palette: palette)
        } else {
            FaceEmpty(symbol: "checklist", title: "هنوز فهرستی نداری", palette: palette)
        }
    }
}

struct TodoContent: View {
    let list: TodoList
    let size: CardSize
    let palette: FacePalette

    private var metrics: TodoMetrics { TodoMetrics.make(size) }

    var body: some View {
        if list.items.isEmpty {
            FaceEmpty(symbol: "checklist", title: "فهرست خالیه، یه کار اضافه کن", palette: palette)
        } else if list.remaining == 0 {
            TodoDone(list: list, size: size, palette: palette)
        } else if size == .medium {
            medium
        } else {
            stacked
        }
    }

    private var stacked: some View {
        VStack(alignment: .leading, spacing: size == .large ? 8 : 6) {
            TodoHeader(list: list, big: size == .large, palette: palette)
            TodoRows(list: list, metrics: metrics, palette: palette)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 18) {
            TodoSummary(list: list, hidden: list.items.count - list.faceEntries(limit: metrics.limit).count, palette: palette)
                .frame(width: 96)
            TodoRows(list: list, metrics: metrics, palette: palette, showsMore: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
