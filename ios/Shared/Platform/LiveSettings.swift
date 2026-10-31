import Observation

@MainActor @Observable
final class LiveSettings {
    static let shared = LiveSettings()

    private var stored: AppSettings
    @ObservationIgnored private var observer: StoreObserver?

    var value: AppSettings {
        get { stored }
        set {
            guard newValue != stored else { return }
            stored = newValue
            Store.settings = newValue
        }
    }

    private init() {
        stored = Store.settings
        observer = StoreObserver { [weak self] in self?.reload() }
    }

    func reload() {
        let fresh = Store.settings
        if fresh != stored {
            stored = fresh
        }
    }
}
