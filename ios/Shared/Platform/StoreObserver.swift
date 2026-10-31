import Foundation

final class StoreObserver {
    private var token: NSObjectProtocol?

    init(_ handler: @escaping @MainActor () -> Void) {
        token = NotificationCenter.default.addObserver(forName: .pingoStoreChanged, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated { handler() }
        }
    }

    deinit {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
    }
}
