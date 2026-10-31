import SwiftUI

struct HabitStatsPanel: View {
    let item: HabitItem
    let tint: Color

    private var streak: Int { item.streak(asOf: .now) }

    var body: some View {
        VStack(spacing: 18) {
            streakRow
            HStack(spacing: 8) {
                HabitStat(value: Persian.number(item.bestStreak()), caption: "بهترین زنجیره")
                HabitStat(value: Persian.percent(item.rate(lastDays: 30, asOf: .now)), caption: "\(Persian.number(30)) روز اخیر")
                HabitStat(value: Persian.number(item.days.count), caption: "کل روزها")
            }
        }
        .panel()
        .animation(.liquid, value: item.days)
    }

    private var streakRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: item.symbol)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(tint)
                .symbolEffect(.bounce, value: streak)
            Text(Persian.number(streak))
                .dasto(56)
                .contentTransition(.numericText(value: Double(streak)))
            Text("روز پشت سر هم")
                .dasto(16)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HabitStat: View {
    let value: String
    let caption: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .dasto(22)
                .contentTransition(.numericText())
            Text(caption)
                .dasto(12)
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
