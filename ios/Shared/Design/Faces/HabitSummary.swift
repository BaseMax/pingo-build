import SwiftUI

struct HabitSummary: View {
    let item: HabitItem
    let date: Date
    let palette: FacePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 4)
            streak
            HabitToggle(habitID: item.id, done: item.isDone(date), palette: palette)
                .padding(.top, 6)
        }
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: item.symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(palette.accent)
                .faceAccent()
            Text(item.title.isEmpty ? "عادت" : item.title)
                .dasto(14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
        }
        .frame(height: 18)
    }

    private var streak: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(Persian.number(item.streak(asOf: date)))
                .dasto(38)
                .foregroundStyle(palette.ink)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("روز")
                .dasto(14)
                .foregroundStyle(palette.soft)
        }
    }
}
