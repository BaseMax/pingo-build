import Foundation
import UserNotifications

enum ReminderScheduler {
    static let identifierPrefix = "pingo.expiry"
    static let message = "اعتبار پینگو داره تموم می‌شه. گوشی رو وصل کن و توی Xcode یک بار Run بزن."

    static func refresh() async {
        let center = UNUserNotificationCenter.current()
        await removePending(from: center)
        guard await remindersEnabled(),
              await isAuthorized(center),
              let expiry = ProvisioningProfile.embedded(in: .main)?.expirationDate else { return }
        for (index, date) in Expiry.reminderDates(expiry: expiry, now: Date()).enumerated() {
            try? await center.add(request(for: date, index: index))
        }
    }

    static func requestAuthorization() async -> Bool {
        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    private static func remindersEnabled() async -> Bool {
        await MainActor.run { LiveSettings.shared.value.reminders }
    }

    private static func isAuthorized(_ center: UNUserNotificationCenter) async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }

    private static func removePending(from center: UNUserNotificationCenter) async {
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private static func request(for date: Date, index: Int) -> UNNotificationRequest {
        UNNotificationRequest(identifier: "\(identifierPrefix).\(index)", content: content(), trigger: trigger(for: date))
    }

    private static func content() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "پینگو"
        content.body = message
        content.sound = .default
        return content
    }

    private static func trigger(for date: Date) -> UNCalendarNotificationTrigger {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
}
