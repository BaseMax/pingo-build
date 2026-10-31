import SwiftUI

struct HabitCalendar: View {
    let item: HabitItem
    let tint: Color
    let onToggle: (Date) -> Void
    @State private var monthOffset = 0

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var month: Date {
        Persian.calendar.date(byAdding: .month, value: monthOffset, to: .now) ?? .now
    }

    private var monthStart: Date {
        Persian.calendar.dateInterval(of: .month, for: month)?.start ?? month
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            weekdays
            ZStack {
                grid
                    .id(monthOffset)
                    .transition(.blurFade)
            }
            .animation(.liquid, value: monthOffset)
        }
        .panel()
    }

    private var header: some View {
        HStack {
            LiquidIconButton(symbol: "chevron.backward") { shiftMonth(-1) }
                .accessibilityLabel("ماه قبل")
            Spacer()
            Text(Persian.monthTitle(month))
                .dasto(18)
                .contentTransition(.opacity)
                .animation(.liquid, value: monthOffset)
            Spacer()
            LiquidIconButton(symbol: "chevron.forward") { shiftMonth(1) }
                .disabled(monthOffset >= 0)
                .opacity(monthOffset >= 0 ? 0.35 : 1)
                .accessibilityLabel("ماه بعد")
        }
    }

    private var weekdays: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(Persian.weekdayLetters, id: \.self) { letter in
                Text(letter)
                    .dasto(12)
                    .foregroundStyle(Color.secondary)
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(Persian.monthCells(for: month).enumerated()), id: \.offset) { _, day in
                cell(day)
            }
        }
    }

    @ViewBuilder
    private func cell(_ day: Int?) -> some View {
        if let day {
            let date = Persian.shift(monthStart, days: day - 1)
            HabitDayCell(
                day: day,
                done: item.isDone(date),
                isToday: Persian.daysBetween(date, .now) == 0,
                isFuture: Persian.daysBetween(date, .now) < 0,
                tint: tint
            ) {
                onToggle(date)
            }
        } else {
            Color.clear.frame(height: 40)
        }
    }

    private func shiftMonth(_ delta: Int) {
        Haptics.selection()
        monthOffset += delta
    }
}
