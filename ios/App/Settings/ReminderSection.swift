import SwiftUI
import UIKit

struct ReminderSection: View {
    private let live = LiveSettings.shared
    @State private var access = ReminderAccess.undetermined

    private var isDenied: Bool { access == .denied }

    private var isOn: Binding<Bool> {
        Binding(
            get: { live.value.reminders && !isDenied },
            set: { change(to: $0) }
        )
    }

    var body: some View {
        SettingsGroup("اعلان‌ها", symbol: "bell.badge.fill") {
            LiquidToggleRow("یادآوری تمدید اعتبار", symbol: "bell.fill", isOn: isOn)
            hint
            if isDenied {
                settingsButton.transition(.blurFade)
            }
        }
        .animation(.liquid, value: access)
        .reloadsOnActive { Task { await reload() } }
    }

    private var hint: some View {
        Text(isDenied ? "اجازه اعلان داده نشده. از تنظیمات آیفون، بخش پینگو، اعلان‌ها رو روشن کن." : "یک روز و سه ساعت قبل از تموم شدن اعتبار نصب بهت خبر می‌دم.")
            .dasto(13)
            .foregroundStyle(isDenied ? Color.red : Color.secondary)
            .lineSpacing(3)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentTransition(.opacity)
    }

    private var settingsButton: some View {
        Button {
            Haptics.tap()
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } label: {
            Label("باز کردن تنظیمات آیفون", systemImage: "gearshape.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.liquid)
    }

    private func change(to enabled: Bool) {
        live.value.reminders = enabled
        Task { await apply(enabled) }
    }

    private func apply(_ enabled: Bool) async {
        if enabled, await ReminderAccess.current() == .undetermined {
            _ = await ReminderScheduler.requestAuthorization()
        }
        await ReminderScheduler.refresh()
        await reload()
    }

    private func reload() async {
        access = await ReminderAccess.current()
    }
}
