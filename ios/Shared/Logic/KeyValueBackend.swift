import Foundation

protocol KeyValueBackend: AnyObject {
    func data(for key: String) -> Data?
    func set(_ data: Data?, for key: String)
}

final class MemoryBackend: KeyValueBackend {
    private var storage: [String: Data] = [:]
    private let lock = NSLock()

    init() {}

    func data(for key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }

    func set(_ data: Data?, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        storage[key] = data
    }
}

final class DefaultsBackend: KeyValueBackend {
    private let defaults: UserDefaults

    init(_ defaults: UserDefaults) {
        self.defaults = defaults
    }

    func data(for key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func set(_ data: Data?, for key: String) {
        if let data {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}
