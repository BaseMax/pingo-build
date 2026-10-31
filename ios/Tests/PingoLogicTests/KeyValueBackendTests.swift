import XCTest
@testable import PingoLogic

final class KeyValueBackendTests: XCTestCase {
    func testMemoryBackendStoresAndRemoves() {
        let backend = MemoryBackend()
        XCTAssertNil(backend.data(for: "a"))
        backend.set(Data([1, 2]), for: "a")
        XCTAssertEqual(backend.data(for: "a"), Data([1, 2]))
        backend.set(nil, for: "a")
        XCTAssertNil(backend.data(for: "a"))
    }

    func testMemoryBackendKeysAreIndependent() {
        let backend = MemoryBackend()
        backend.set(Data([1]), for: "a")
        backend.set(Data([2]), for: "b")
        XCTAssertEqual(backend.data(for: "a"), Data([1]))
        XCTAssertEqual(backend.data(for: "b"), Data([2]))
    }

    func testDefaultsBackendStoresAndRemoves() throws {
        let suite = "pingo.tests." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let backend = DefaultsBackend(defaults)
        backend.set(Data([9]), for: "k")
        XCTAssertEqual(backend.data(for: "k"), Data([9]))
        backend.set(nil, for: "k")
        XCTAssertNil(backend.data(for: "k"))
    }
}
