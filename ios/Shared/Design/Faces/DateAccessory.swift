import SwiftUI
import WidgetKit

struct DateAccessory: View {
    let date: Date
    let shape: AccessoryShape
    let showsGregorian: Bool

    var body: some View {
        content.environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    private var content: some View {
        switch shape {
        case .circular: circular
        case .rectangular: rectangular
        case .inline: Text(DateText.inline(date))
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            Gauge(value: Persian.fraction(.month, at: date)) {
                Text(Persian.monthName(date))
            } currentValueLabel: {
                Text(Persian.number(Persian.dayNumber(date)))
                    .dasto(18)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .faceAccent()
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(Persian.weekdayName(date))
                .dasto(16)
                .faceAccent()
            Text(Persian.shortDate(date))
                .dasto(14)
            if showsGregorian {
                Text(DateText.gregorian(date))
                    .dasto(11)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
