import SwiftUI

struct TodoHeader: View {
    let list: TodoList
    let big: Bool
    let palette: FacePalette

    var body: some View {
        HStack(spacing: 8) {
            Text(list.title.isEmpty ? "فهرست کارها" : list.title)
                .dasto(big ? 17 : 14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(Persian.number(list.remaining))
                .dasto(big ? 20 : 16)
                .foregroundStyle(palette.accent)
                .faceAccent()
                .contentTransition(.numericText())
        }
        .frame(height: big ? 24 : 18)
    }
}

struct TodoSummary: View {
    let list: TodoList
    let hidden: Int
    let palette: FacePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(list.title.isEmpty ? "فهرست کارها" : list.title)
                .dasto(14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(Persian.number(list.remaining))
                .dasto(40)
                .foregroundStyle(palette.accent)
                .faceAccent()
                .contentTransition(.numericText())
            Text("کار مونده")
                .dasto(13)
                .foregroundStyle(palette.soft)
            if hidden > 0 {
                TodoMore(count: hidden, palette: palette).padding(.top, 4)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct TodoDone: View {
    let list: TodoList
    let size: CardSize
    let palette: FacePalette

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(palette.accent).faceAccent()
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(palette.onAccent)
            }
            .frame(width: 46, height: 46)
            Text("همه کارها انجام شد")
                .dasto(size == .small ? 14 : 17)
                .foregroundStyle(palette.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(list.title.isEmpty ? "فهرست کارها" : list.title)
                .dasto(12)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
