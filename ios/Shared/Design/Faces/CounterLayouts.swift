import SwiftUI

struct CounterSmall: View {
    let item: CounterItem
    let date: Date
    let palette: FacePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CounterHeader(item: item, palette: palette)
            Spacer(minLength: 4)
            HStack(spacing: 0) {
                CounterRing(fraction: item.shownProgress(on: date), width: 8, color: palette.accent, track: palette.track) {
                    CounterCenter(item: item, date: date, palette: palette)
                }
                .frame(width: 80, height: 80)
                Spacer(minLength: 8)
                CounterStepButton(counterID: item.id, delta: 1, diameter: 36, dimmed: false, palette: palette)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CounterMedium: View {
    let item: CounterItem
    let date: Date
    let palette: FacePalette

    var body: some View {
        HStack(spacing: 18) {
            CounterRing(fraction: item.shownProgress(on: date), width: 11, color: palette.accent, track: palette.track) {
                CounterGlyph(item: item, date: date, palette: palette)
            }
            .frame(width: 112, height: 112)
            VStack(alignment: .leading, spacing: 0) {
                Text(item.title.isEmpty ? "شمارنده" : item.title)
                    .dasto(15)
                    .foregroundStyle(palette.soft)
                    .lineLimit(1)
                    .frame(height: 20)
                Spacer(minLength: 2)
                total
                Spacer(minLength: 6)
                buttons
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var total: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(Persian.number(item.shownCount(on: date)))
                .dasto(36)
                .foregroundStyle(item.reachedShownGoal(on: date) ? palette.accent : palette.ink)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("از هدف " + Persian.number(item.goal))
                .dasto(14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
        }
    }

    private var buttons: some View {
        HStack(spacing: 10) {
            CounterStepButton(counterID: item.id, delta: -1, diameter: 38, dimmed: item.count(on: date) == 0, palette: palette)
            CounterStepButton(counterID: item.id, delta: 1, diameter: 38, dimmed: false, palette: palette)
        }
    }
}
