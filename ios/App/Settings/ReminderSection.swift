import SwiftUI

struct ReminderSection: View {
    @Bindable private var live = LiveSettings.shared
    @State private var denied = false

    var body: some View {
        SettingsGroup("اعلان‌ها", symbol: "bell.badge.fill") {
            LiquidToggleRow("یادآوری تمدید اعتبار", symbol: "bell.fill", isOn: $live.value.reminders)
            hint
        }
        .animation(.liquid, value: denied)
        .onChange(of: live.value.reminders) { _, enabled in
            Task { await apply(enabled) }
        }
        .task { await ReminderScheduler.refresh() }
    }

    private var hint: some View {
        Text(denied ? "اجازه اعلان داده نشده. از تنظیمات آیفون، بخش پینگو، اعلان‌ها رو روشن کن." : ExpiryCopy.reminderHint)
            .dasto(13)
            .foregroundStyle(denied ? Color.red : Color.secondary)
            .lineSpacing(3)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentTransition(.opacity)
    }

    private func apply(_ enabled: Bool) async {
        if enabled {
            let granted = await ReminderScheduler.requestAuthorization()
            denied = !granted
            if !granted {
                live.value.reminders = false
            }
        }
        await ReminderScheduler.refresh()
    }
}
