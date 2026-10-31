import SwiftUI

struct AlbumIntervalRow: View {
    @Binding var minutes: Int

    private var options: [Int] {
        let presets = Presets.albumIntervals.map { $0.minutes }
        return presets.contains(minutes) ? presets : presets + [minutes]
    }

    var body: some View {
        LiquidRow(
            title: "تعویض عکس",
            subtitle: nil,
            leading: { RowSymbolTile(symbol: "timer") },
            trailing: { picker }
        )
    }

    private var picker: some View {
        Picker("تعویض عکس", selection: $minutes) {
            ForEach(options, id: \.self) { value in
                Text(title(for: value)).tag(value)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .tint(Color.signal)
    }

    private func title(for value: Int) -> String {
        Presets.albumIntervals.first { $0.minutes == value }?.title ?? "هر \(Persian.number(value)) دقیقه"
    }
}
