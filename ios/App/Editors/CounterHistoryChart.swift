import Charts
import SwiftUI

struct CounterHistoryChart: View {
    let item: CounterItem
    let tint: Color

    private var days: [CounterDay] {
        item.history(14, asOf: .now).map { CounterDay(day: $0.day, count: $0.count) }
    }

    private var ceiling: Int {
        max(item.goal, days.map(\.count).max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(Persian.number(14)) روز اخیر")
                .dasto(16)
                .foregroundStyle(Color.secondary)
            chart
                .frame(height: 180)
            Divider()
            HStack {
                Text("مجموع از اولش")
                    .dasto(15)
                    .foregroundStyle(Color.secondary)
                Spacer()
                Text(Persian.number(item.total))
                    .dasto(20)
                    .contentTransition(.numericText(value: Double(item.total)))
            }
        }
        .panel()
        .animation(.liquid, value: item.counts)
    }

    private var chart: some View {
        Chart {
            ForEach(days) { entry in
                BarMark(
                    x: .value("روز", entry.day, unit: .day),
                    y: .value("تعداد", entry.count)
                )
                .foregroundStyle(entry.isToday ? tint : tint.opacity(0.5))
                .cornerRadius(5)
            }
            RuleMark(y: .value("هدف", item.goal))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                .foregroundStyle(Color.secondary)
        }
        .chartYScale(domain: 0...ceiling)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) { value in
                AxisValueLabel {
                    dayLabel(value)
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisValueLabel {
                    countLabel(value)
                }
            }
        }
    }

    @ViewBuilder
    private func dayLabel(_ value: AxisValue) -> some View {
        if let date = value.as(Date.self) {
            Text(Persian.number(Persian.dayNumber(date))).dasto(11)
        }
    }

    @ViewBuilder
    private func countLabel(_ value: AxisValue) -> some View {
        if let count = value.as(Int.self) {
            Text(Persian.number(count)).dasto(11)
        }
    }
}
