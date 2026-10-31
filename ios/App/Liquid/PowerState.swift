import Foundation
import Observation

@MainActor @Observable
final class PowerState {
    static let shared = PowerState()

    private(set) var isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
    @ObservationIgnored private var token: NSObjectProtocol?

    private init() {
        token = NotificationCenter.default.addObserver(forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }

    private func refresh() {
        isLowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
    }
}
