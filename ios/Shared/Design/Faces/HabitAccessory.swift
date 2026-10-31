import SwiftUI
import WidgetKit

struct HabitAccessory: View {
    let item: HabitItem?
    let date: Date

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Gauge(value: item?.rate(lastDays: 7, asOf: date) ?? 0) {
                Image(systemName: item?.symbol ?? "flame.fill")
            } currentValueLabel: {
                Text(Persian.number(item?.streak(asOf: date) ?? 0))
            }
            .gaugeStyle(.accessoryCircular)
            .faceAccent()
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
