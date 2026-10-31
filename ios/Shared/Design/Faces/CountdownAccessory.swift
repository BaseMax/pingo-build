import SwiftUI
import WidgetKit

struct CountdownAccessory: View {
    let item: CountdownItem?
    let date: Date
    let shape: AccessoryShape

    var body: some View {
        content.environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder private var content: some View {
        if let item {
            CountdownAccessoryBody(info: CountdownInfo(item: item, date: date), shape: shape)
        } else {
            CountdownAccessoryEmpty(shape: shape)
        }
    }
}

struct CountdownAccessoryBody: View {
    let info: CountdownInfo
    let shape: AccessoryShape

    var body: some View {
        switch shape {
        case .circular: circular
        case .rectangular: rectangular
        case .inline: Text(info.inlineText)
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            Gauge(value: info.progress) {
                Text("روز")
            } currentValueLabel: {
                CountdownGaugeValue(info: info)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .widgetAccentable()
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: info.symbol).font(.system(size: 12, weight: .semibold))
                Text(info.title).dasto(13).lineLimit(1)
            }
            .widgetAccentable()
            amount
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var amount: some View {
        if info.isToday {
            Text("امروزه!").dasto(26).lineLimit(1)
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(info.number)
                    .dasto(30)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .contentTransition(.numericText())
                Text(info.caption).dasto(13).foregroundStyle(.secondary)
            }
        }
    }
}

struct CountdownGaugeValue: View {
    let info: CountdownInfo

    var body: some View {
        if info.isToday {
            Image(systemName: "party.popper.fill").font(.system(size: 18, weight: .semibold))
        } else {
            Text(info.number)
                .dasto(18)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct CountdownAccessoryEmpty: View {
    let shape: AccessoryShape

    var body: some View {
        switch shape {
        case .circular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "hourglass").font(.system(size: 20, weight: .semibold))
            }
        case .rectangular:
            Text("یه شمارش معکوس بساز")
                .dasto(14)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .inline:
            Text("شمارش معکوس بساز")
        }
    }
}
