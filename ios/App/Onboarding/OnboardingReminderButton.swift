import SwiftUI

struct OnboardingReminderButton: View {
    @State private var granted = false

    var body: some View {
        Button {
            Task { await request() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: granted ? "bell.badge.fill" : "bell.fill")
                    .contentTransition(.symbolEffect(.replace))
                Text(granted ? "یادآوری روشنه" : "یادآوری تمدید اعتبار")
                    .contentTransition(.opacity)
            }
        }
        .buttonStyle(.liquid)
        .animation(.liquid, value: granted)
    }

    private func request() async {
        guard !granted else { return }
        let allowed = await ReminderScheduler.requestAuthorization()
        guard allowed else {
            Haptics.warning()
            return
        }
        granted = true
        Haptics.success()
        await ReminderScheduler.refresh()
    }
}
