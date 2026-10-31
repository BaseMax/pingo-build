import XCTest
@testable import PingoLogic

final class BackupTests: XCTestCase {
    private func populate() {
        Store.backend = MemoryBackend()
        Store.notes.add(NoteItem(id: "n", text: "سلام", theme: .sand, updated: Date(timeIntervalSince1970: 1_750_000_000)))
        Store.countdowns.add(CountdownItem(id: "c", title: "سفر", date: Date(timeIntervalSince1970: 1_760_000_000)))
        Store.habits.add(HabitItem(id: "h", title: "ورزش", days: ["2025-05-01", "2025-05-02"]))
        Store.todos.add(TodoList(id: "t", title: "کارها", items: [TodoEntry(id: "e", text: "نان", done: true)]))
        Store.counters.add(CounterItem(id: "k", title: "آب", counts: ["2025-05-01": 5]))
        Store.albums.add(AlbumItem(id: "a", title: "عکس", photos: ["p1.jpg", "p2.jpg", "missing.jpg"]))
        var settings = Store.settings
        settings.haptics = false
        settings.onboarded = true
        settings.kindThemes["moon"] = .leaf
        Store.settings = settings
    }

    private let blobs: [String: Data] = ["p1.jpg": Data([1, 2, 3]), "p2.jpg": Data([4, 5])]

    func testMakeCollectsEverythingAndOnlyExistingPhotos() {
        populate()
        let backup = Backup.make { self.blobs[$0] }
        XCTAssertEqual(backup.version, 1)
        XCTAssertEqual(backup.notes.map(\.id), ["n"])
        XCTAssertEqual(backup.countdowns.map(\.id), ["c"])
        XCTAssertEqual(backup.habits.map(\.id), ["h"])
        XCTAssertEqual(backup.todos.map(\.id), ["t"])
        XCTAssertEqual(backup.counters.map(\.id), ["k"])
        XCTAssertEqual(backup.albums.map(\.id), ["a"])
        XCTAssertEqual(backup.photos, blobs)
        XCTAssertFalse(backup.settings.haptics)
    }

    func testEncodedIsPrettyAndSorted() throws {
        populate()
        let text = String(decoding: try Backup.make { self.blobs[$0] }.encoded(), as: UTF8.self)
        XCTAssertTrue(text.contains("\n"))
        let albums = try XCTUnwrap(text.range(of: "\"albums\""))
        let version = try XCTUnwrap(text.range(of: "\"version\""))
        XCTAssertLessThan(albums.lowerBound, version.lowerBound)
    }

    func testRoundTripThroughRestore() throws {
        populate()
        let original = Backup.make { self.blobs[$0] }
        let data = try original.encoded()

        Store.backend = MemoryBackend()
        var saved: [String: Data] = [:]
        try Backup.decoded(from: data).restore { saved[$0] = $1 }

        XCTAssertEqual(saved, blobs)
        XCTAssertEqual(Store.notes.all, original.notes)
        XCTAssertEqual(Store.countdowns.all, original.countdowns)
        XCTAssertEqual(Store.habits.all, original.habits)
        XCTAssertEqual(Store.todos.all, original.todos)
        XCTAssertEqual(Store.counters.all, original.counters)
        XCTAssertEqual(Store.albums.all, original.albums)
        XCTAssertEqual(Store.settings, original.settings)
        XCTAssertEqual(Store.settings.kindThemes["moon"], .leaf)
    }

    func testRestoreReplacesExistingData() throws {
        populate()
        let data = try Backup.make { self.blobs[$0] }.encoded()
        Store.notes.add(NoteItem(id: "extra"))
        _ = Store.create(.habit)
        try Backup.decoded(from: data).restore { _, _ in }
        XCTAssertEqual(Store.notes.all.map(\.id), ["n"])
        XCTAssertEqual(Store.habits.all.map(\.id), ["h"])
    }

    func testRestoreKeepsOnboardedWhenAlreadyTrue() throws {
        Store.backend = MemoryBackend()
        var fresh = AppSettings()
        fresh.onboarded = false
        let backup = Backup(version: 1, exportedAt: .now, notes: [], countdowns: [], habits: [], todos: [], counters: [], albums: [], settings: fresh, photos: [:])
        var current = Store.settings
        current.onboarded = true
        Store.settings = current
        backup.restore { _, _ in }
        XCTAssertTrue(Store.settings.onboarded)
    }

    func testRestoreDoesNotInventOnboarded() {
        Store.backend = MemoryBackend()
        let backup = Backup(version: 1, exportedAt: .now, notes: [], countdowns: [], habits: [], todos: [], counters: [], albums: [], settings: AppSettings(), photos: [:])
        backup.restore { _, _ in }
        XCTAssertFalse(Store.settings.onboarded)
    }

    func testDecodeRejectsGarbageAndFutureVersions() throws {
        XCTAssertThrowsError(try Backup.decoded(from: Data("nope".utf8)))
        Store.backend = MemoryBackend()
        var future = Backup.make { _ in nil }
        future.version = 2
        XCTAssertThrowsError(try Backup.decoded(from: try future.encoded()))
    }

    func testRestoreNotifiesOnce() throws {
        populate()
        let backup = Backup.make { self.blobs[$0] }
        var received: [PingoKind?] = []
        let original = Store.onChange
        Store.onChange = { received.append($0) }
        defer { Store.onChange = original }
        backup.restore { _, _ in }
        XCTAssertEqual(received, [nil])
    }
}
