import UserNotifications

enum ReminderAccess: Equatable {
    case undetermined
    case granted
    case denied

    static func current() async -> ReminderAccess {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        switch status {
        case .notDetermined: return .undetermined
        case .authorized, .provisional, .ephemeral: return .granted
        default: return .denied
        }
    }
}
