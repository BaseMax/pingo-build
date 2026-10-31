import UIKit

@MainActor
enum Haptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let picker = UISelectionFeedbackGenerator()
    private static let notifier = UINotificationFeedbackGenerator()

    private static var isEnabled: Bool { LiveSettings.shared.value.haptics }

    static func tap() {
        guard isEnabled else { return }
        light.impactOccurred()
        light.prepare()
    }

    static func soft() {
        guard isEnabled else { return }
        softImpact.impactOccurred()
        softImpact.prepare()
    }

    static func selection() {
        guard isEnabled else { return }
        picker.selectionChanged()
        picker.prepare()
    }

    static func success() {
        notify(.success)
    }

    static func warning() {
        notify(.warning)
    }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        notifier.notificationOccurred(type)
        notifier.prepare()
    }
}
