import SwiftUI
import WidgetKit

struct CounterAccessory: View {
    let item: CounterItem?
    let date: Date

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Gauge(value: item?.progress(on: date) ?? 0) {
                Image(systemName: item?.symbol ?? "plus.circle.fill")
            } currentValueLabel: {
                Text(Persian.number(item?.count(on: date) ?? 0))
            }
            .gaugeStyle(.accessoryCircular)
            .faceAccent()
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
