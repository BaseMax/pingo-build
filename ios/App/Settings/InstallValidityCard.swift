import SwiftUI

struct InstallValidityCard: View {
    let expiry: Date?
    let now: Date

    private var status: ExpiryStatus { Expiry.status(expiry: expiry, now: now) }

    private var message: String {
        guard status.level == .unknown else { return status.message }
        return "اعتبار این نصب قابل خوندن نیست. روی شبیه‌ساز یا TestFlight طبیعیه و جای نگرانی نیست."
    }

    var body: some View {
        VStack(spacing: 14) {
            ValidityRing(status: status)
            Text(status.level.title)
                .dasto(20)
                .foregroundStyle(status.level.color)
                .contentTransition(.opacity)
            Text(message)
                .dasto(14)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            endDate
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .panel()
        .animation(.liquid, value: status)
    }

    @ViewBuilder
    private var endDate: some View {
        if let expiry, status.level != .unknown {
            Text("پایان اعتبار: " + Persian.shortDate(expiry) + " ساعت " + Persian.format(expiry, "HH:mm"))
                .dasto(13)
                .foregroundStyle(Color.secondary.opacity(0.8))
        }
    }
}
