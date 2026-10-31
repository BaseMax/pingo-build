import SwiftUI

struct CounterHeader: View {
    let item: CounterItem
    let palette: FacePalette

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: item.symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(palette.accent)
                .faceAccent()
            Text(item.title.isEmpty ? "شمارنده" : item.title)
                .dasto(14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
        }
        .frame(height: 18)
    }
}

struct CounterCenter: View {
    let item: CounterItem
    let date: Date
    let palette: FacePalette

    private var reached: Bool { item.reachedShownGoal(on: date) }

    var body: some View {
        VStack(spacing: 0) {
            Text(Persian.number(item.shownCount(on: date)))
                .dasto(26)
                .foregroundStyle(reached ? palette.accent : palette.ink)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            goalLine
        }
        .padding(.horizontal, 12)
    }

    @ViewBuilder private var goalLine: some View {
        if reached {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(palette.accent)
                .faceAccent()
        } else {
            Text("از " + Persian.number(item.goal))
                .dasto(11)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
        }
    }
}

struct CounterGlyph: View {
    let item: CounterItem
    let date: Date
    let palette: FacePalette

    var body: some View {
        Image(systemName: item.reachedShownGoal(on: date) ? "checkmark" : item.symbol)
            .font(.system(size: 30, weight: .semibold))
            .foregroundStyle(palette.accent)
            .faceAccent()
    }
}
