import SwiftUI

struct AppearanceSection: View {
    @Bindable private var live = LiveSettings.shared

    var body: some View {
        SettingsGroup("ظاهر و حس", symbol: "paintbrush.fill") {
            appearancePicker
            LiquidToggleRow("لرزش لمسی", symbol: "hand.tap.fill", isOn: $live.value.haptics)
        }
        .onChange(of: live.value.haptics) { _, enabled in
            if enabled {
                Haptics.success()
            }
        }
    }

    private var appearancePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("حالت نمایش").dasto(16)
            LiquidSegmented(Appearance.allCases, selection: $live.value.appearance) { $0.title }
        }
        .panel()
    }
}
