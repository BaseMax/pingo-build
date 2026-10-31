import XCTest
@testable import PingoLogic

final class StoreTests: XCTestCase {
    private func freshStore() {
        Store.backend = MemoryBackend()
    }

    func testThemeFallsBackToKindDefault() {
        freshStore()
        for kind in PingoKind.allCases {
            XCTAssertEqual(Store.theme(for: kind), kind.defaultTheme)
        }
    }

    func testSetThemeOverridesKindDefault() {
        freshStore()
        Store.setTheme(.leaf, for: .clock)
        XCTAssertEqual(Store.theme(for: .clock), .leaf)
        XCTAssertEqual(Store.theme(for: .moon), PingoKind.moon.defaultTheme)
        XCTAssertEqual(Store.settings.kindThemes["clock"], .leaf)
    }

    func testThemeResolutionOrder() {
        freshStore()
        let id = Store.create(.habit)
        XCTAssertEqual(Store.theme(for: .habit, selection: WidgetSelection(itemID: id)), PingoKind.habit.defaultTheme)

        Store.setTheme(.paper, for: .habit)
        XCTAssertEqual(Store.theme(for: .habit, selection: WidgetSelection(itemID: id)), .paper)

        Store.habits.update(id) { $0.theme = .sky }
        XCTAssertEqual(Store.theme(for: .habit, selection: WidgetSelection(itemID: id)), .sky)
        XCTAssertEqual(Store.theme(for: .habit, selection: WidgetSelection()), .sky)
        XCTAssertEqual(Store.theme(for: .habit), .paper)

        XCTAssertEqual(Store.theme(for: .habit, selection: WidgetSelection(itemID: id, theme: .ink)), .ink)
    }

    func testThemeForKindWithoutLibraryIgnoresItems() {
        freshStore()
        Store.setTheme(.sand, for: .date)
        XCTAssertEqual(Store.theme(for: .date, selection: WidgetSelection(itemID: "x")), .sand)
    }

    func testCreateAddsDefaultItems() {
        freshStore()
        let note = Store.create(.note)
        let countdown = Store.create(.countdown)
        let habit = Store.create(.habit)
        let todo = Store.create(.todo)
        let counter = Store.create(.counter)
        let album = Store.create(.album)
        XCTAssertEqual(Store.notes.item(note)?.text, "")
        XCTAssertEqual(Store.habits.item(habit)?.title, "عادت جدید")
        XCTAssertEqual(Store.todos.item(todo)?.title, "فهرست جدید")
        XCTAssertEqual(Store.counters.item(counter)?.title, "شمارنده جدید")
        XCTAssertEqual(Store.albums.item(album)?.title, "آلبوم جدید")
        let event = Store.countdowns.item(countdown)
        XCTAssertEqual(event?.title, "رویداد جدید")
        XCTAssertEqual(Persian.daysBetween(.now, event?.date ?? .now), 30)
    }

    func testCountTracksEveryKind() {
        freshStore()
        for kind in LibraryKind.allCases {
            XCTAssertEqual(Store.count(of: kind), 0)
            _ = Store.create(kind)
            _ = Store.create(kind)
            XCTAssertEqual(Store.count(of: kind), 2)
        }
    }

    func testCreateReturnsUniqueIds() {
        freshStore()
        XCTAssertNotEqual(Store.create(.note), Store.create(.note))
    }

    func testPrepareSeedsOnce() {
        freshStore()
        Store.prepare()
        XCTAssertTrue(Store.settings.seeded)
        XCTAssertEqual(Store.notes.all.first?.text, "امروز چه کاری از همه مهم‌تره؟")
        XCTAssertEqual(Store.countdowns.all.first?.title, "سفر بعدی")
        XCTAssertEqual(Persian.daysBetween(.now, Store.countdowns.all.first?.date ?? .now), 30)
        XCTAssertEqual(Store.habits.all.first?.title, "ورزش")
        XCTAssertEqual(Store.todos.all.first?.title, "کارهای امروز")
        XCTAssertEqual(Store.todos.all.first?.items.count, 3)
        XCTAssertEqual(Store.counters.all.first?.title, "آب")
        XCTAssertEqual(Store.counters.all.first?.goal, 8)
        XCTAssertTrue(Store.albums.all.isEmpty)
    }

    func testPrepareIsIdempotent() {
        freshStore()
        Store.prepare()
        Store.prepare()
        for kind in LibraryKind.allCases where kind != .album {
            XCTAssertEqual(Store.count(of: kind), 1)
        }
        let id = Store.notes.all[0].id
        Store.notes.remove(id)
        Store.prepare()
        XCTAssertEqual(Store.count(of: .note), 0)
    }

    func testPrepareLeavesExistingDataAlone() {
        freshStore()
        _ = Store.create(.habit)
        Store.prepare()
        XCTAssertEqual(Store.count(of: .habit), 1)
        XCTAssertEqual(Store.count(of: .note), 0)
        XCTAssertFalse(Store.settings.seeded)
    }

    func testSettingsPersist() {
        freshStore()
        XCTAssertEqual(Store.settings, AppSettings())
        var settings = Store.settings
        settings.haptics = false
        settings.appearance = .dark
        settings.falSeed = 4
        settings.kindThemes["fal"] = .ink
        Store.settings = settings
        XCTAssertEqual(Store.settings, settings)
    }

    func testCorruptSettingsReadAsDefaults() {
        freshStore()
        Store.backend.set(Data("{".utf8), for: "settings")
        XCTAssertEqual(Store.settings, AppSettings())
    }

    func testOnChangeFiresForSettingsAndThemes() {
        freshStore()
        var received: [PingoKind?] = []
        let original = Store.onChange
        Store.onChange = { received.append($0) }
        defer { Store.onChange = original }
        Store.settings = AppSettings()
        Store.setTheme(.leaf, for: .moon)
        Store.touch(.fal)
        XCTAssertEqual(received, [nil, .moon, .fal])
    }

    func testItemStoresReportTheirWidgetKind() {
        freshStore()
        var received: [PingoKind?] = []
        let original = Store.onChange
        Store.onChange = { received.append($0) }
        defer { Store.onChange = original }
        for kind in LibraryKind.allCases { _ = Store.create(kind) }
        XCTAssertEqual(received, LibraryKind.allCases.map { Optional($0.widget) })
    }

    func testDefaultOnChangePostsNotification() {
        freshStore()
        let posted = expectation(description: "posted")
        posted.assertForOverFulfill = false
        let token = NotificationCenter.default.addObserver(forName: .pingoStoreChanged, object: nil, queue: nil) { _ in posted.fulfill() }
        defer { NotificationCenter.default.removeObserver(token) }
        Store.touch(.date)
        wait(for: [posted], timeout: 2)
    }
}
