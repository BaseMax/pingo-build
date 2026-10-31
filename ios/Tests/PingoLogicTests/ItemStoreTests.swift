import XCTest
@testable import PingoLogic

final class ItemStoreTests: XCTestCase {
    private func makeStore() -> ItemStore<NoteItem> {
        Store.backend = MemoryBackend()
        return ItemStore<NoteItem>(key: "notes", kind: .note)
    }

    private func notes(_ texts: [String]) -> [NoteItem] {
        texts.map { NoteItem(id: $0, text: $0) }
    }

    func testEmptyByDefault() {
        XCTAssertTrue(makeStore().all.isEmpty)
    }

    func testAddAppendsAndPersists() {
        let store = makeStore()
        store.add(NoteItem(id: "a", text: "one"))
        store.add(NoteItem(id: "b", text: "two"))
        XCTAssertEqual(store.all.map(\.id), ["a", "b"])
        XCTAssertEqual(store.item("b")?.text, "two")
        XCTAssertNil(store.item("zzz"))
    }

    func testUpdateMutatesOnlyThatItem() {
        let store = makeStore()
        store.save(notes(["a", "b", "c"]))
        store.update("b") { $0.text = "changed" }
        XCTAssertEqual(store.all.map(\.text), ["a", "changed", "c"])
    }

    func testUpdateRereadsStoredList() {
        let store = makeStore()
        store.save(notes(["a", "b"]))
        let other = ItemStore<NoteItem>(key: "notes", kind: .note)
        other.add(NoteItem(id: "c", text: "c"))
        store.update("a") { $0.text = "x" }
        XCTAssertEqual(store.all.map(\.id), ["a", "b", "c"])
        XCTAssertEqual(store.item("a")?.text, "x")
    }

    func testUpdateMissingIdDoesNothingAndDoesNotNotify() {
        let store = makeStore()
        store.save(notes(["a"]))
        var fired = 0
        let original = Store.onChange
        Store.onChange = { _ in fired += 1 }
        defer { Store.onChange = original }
        store.update("missing") { $0.text = "x" }
        XCTAssertEqual(fired, 0)
        XCTAssertEqual(store.all.map(\.text), ["a"])
    }

    func testRemove() {
        let store = makeStore()
        store.save(notes(["a", "b", "c"]))
        store.remove("b")
        XCTAssertEqual(store.all.map(\.id), ["a", "c"])
        store.remove("missing")
        XCTAssertEqual(store.all.map(\.id), ["a", "c"])
    }

    func testMoveMatchesSwiftUISemantics() {
        let store = makeStore()
        let expectations: [(IndexSet, Int, [String])] = [
            (IndexSet(integer: 0), 3, ["b", "c", "a", "d"]),
            (IndexSet(integer: 0), 4, ["b", "c", "d", "a"]),
            (IndexSet(integer: 3), 0, ["d", "a", "b", "c"]),
            (IndexSet(integer: 3), 1, ["a", "d", "b", "c"]),
            (IndexSet(integer: 1), 1, ["a", "b", "c", "d"]),
            (IndexSet(integer: 1), 2, ["a", "b", "c", "d"]),
            (IndexSet([0, 1]), 4, ["c", "d", "a", "b"]),
            (IndexSet([2, 3]), 0, ["c", "d", "a", "b"]),
            (IndexSet([0, 2]), 3, ["b", "a", "c", "d"]),
        ]
        for (source, destination, expected) in expectations {
            store.save(notes(["a", "b", "c", "d"]))
            store.move(from: source, to: destination)
            XCTAssertEqual(store.all.map(\.id), expected, "move \(Array(source)) to \(destination)")
        }
    }

    func testMoveIgnoresOutOfRangeSource() {
        let store = makeStore()
        store.save(notes(["a", "b"]))
        store.move(from: IndexSet(integer: 9), to: 0)
        XCTAssertEqual(store.all.map(\.id), ["a", "b"])
    }

    func testResolveFallsBack() {
        let store = makeStore()
        XCTAssertNil(store.resolve(WidgetSelection()))
        store.save(notes(["a", "b"]))
        XCTAssertEqual(store.resolve(WidgetSelection(itemID: "b"))?.id, "b")
        XCTAssertEqual(store.resolve(WidgetSelection(itemID: "gone"))?.id, "a")
        XCTAssertEqual(store.resolve(WidgetSelection())?.id, "a")
    }

    func testCorruptDataReadsAsEmpty() {
        let store = makeStore()
        Store.backend.set(Data("not json".utf8), for: "notes")
        XCTAssertTrue(store.all.isEmpty)
        XCTAssertNil(store.resolve(WidgetSelection()))
        store.add(NoteItem(id: "a", text: "fresh"))
        XCTAssertEqual(store.all.map(\.id), ["a"])
    }

    func testSaveNotifiesWithKind() {
        let store = makeStore()
        var kinds: [PingoKind?] = []
        let original = Store.onChange
        Store.onChange = { kinds.append($0) }
        defer { Store.onChange = original }
        store.add(NoteItem(id: "a"))
        XCTAssertEqual(kinds, [.note])
    }

    func testDatesRoundTripAsISO8601() {
        let store = makeStore()
        let date = Date(timeIntervalSince1970: 1_750_000_000)
        store.save([NoteItem(id: "a", text: "t", theme: .leaf, updated: date)])
        XCTAssertEqual(store.all.first?.updated, date)
        XCTAssertEqual(store.all.first?.theme, .leaf)
        let raw = Store.backend.data(for: "notes").flatMap { String(data: $0, encoding: .utf8) } ?? ""
        XCTAssertTrue(raw.contains("2025-06-15T"))
    }
}
