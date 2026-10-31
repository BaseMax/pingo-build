import SwiftUI

struct HabitWeek: View {
    let item: HabitItem
    let date: Date
    let palette: FacePalette

    private var days: [Date] { item.lastDays(7, asOf: date) }
    private var rate: Double { item.rate(lastDays: 30, asOf: date) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("۳۰ روز اخیر: " + Persian.percent(rate))
                .dasto(13)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(height: 18)
            Spacer(minLength: 4)
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    HabitDay(day: day, done: item.isDone(day), isToday: Persian.calendar.isDate(day, inSameDayAs: date), palette: palette)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct HabitDay: View {
    let day: Date
    let done: Bool
    let isToday: Bool
    let palette: FacePalette

    var body: some View {
        VStack(spacing: 6) {
            Text(Persian.weekdayLetter(day))
                .dasto(12)
                .foregroundStyle(isToday ? palette.ink : palette.soft)
            dot
        }
    }

    private var dot: some View {
        ZStack {
            if done {
                Circle().fill(palette.accent).faceAccent()
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(palette.onAccent)
            } else {
                Circle().fill(palette.track)
                if isToday {
                    Circle().strokeBorder(palette.soft, lineWidth: 1.5)
                }
            }
        }
        .frame(width: 18, height: 18)
    }
}
