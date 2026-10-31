import SwiftUI
import WidgetKit

struct ProgressAccessory: View {
    let date: Date
    let shape: AccessoryShape

    private var slices: [ProgressSlice] { ProgressSlice.all(at: date) }

    var body: some View {
        content.environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    private var content: some View {
        switch shape {
        case .circular: circular
        case .rectangular: rectangular
        case .inline: Text("سال " + Persian.percent(Persian.fraction(.year, at: date)))
        }
    }

    private var circular: some View {
        let value = Persian.fraction(.year, at: date)
        return ZStack {
            AccessoryWidgetBackground()
            Gauge(value: value) {
                Text("سال")
            } currentValueLabel: {
                VStack(spacing: 0) {
                    Text(Persian.number(Int((value * 100).rounded(.down))))
                        .dasto(17)
                    Text("سال")
                        .dasto(9)
                        .foregroundStyle(.secondary)
                }
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .faceAccent()
        }
    }

    private var rectangular: some View {
        VStack(spacing: 3) {
            ForEach(chosen) { slice in
                row(slice)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var chosen: [ProgressSlice] {
        slices.filter { $0.id != 1 }
    }

    private func row(_ slice: ProgressSlice) -> some View {
        HStack(spacing: 6) {
            Text(slice.title)
                .dasto(12)
                .frame(width: 30, alignment: .leading)
            Gauge(value: slice.value) {
                EmptyView()
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .faceAccent()
            Text(slice.percent)
                .dasto(11)
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .trailing)
        }
    }
}
