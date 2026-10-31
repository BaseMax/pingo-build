import XCTest
@testable import PingoLogic

final class TodoMathTests: XCTestCase {
    private func list(_ states: [Bool]) -> TodoList {
        TodoList(title: "t", items: states.enumerated().map { TodoEntry(id: "\($0.offset)", text: "e\($0.offset)", done: $0.element) })
    }

    func testCounts() {
        Store.backend = MemoryBackend()
        let todo = list([true, false, true, false, false])
        XCTAssertEqual(todo.doneCount, 2)
        XCTAssertEqual(todo.remaining, 3)
        XCTAssertEqual(TodoList().doneCount, 0)
        XCTAssertEqual(TodoList().remaining, 0)
    }

    func testToggleFlipsOnlyThatEntry() {
        Store.backend = MemoryBackend()
        var todo = list([false, false])
        todo.toggle("1")
        XCTAssertEqual(todo.items.map(\.done), [false, true])
        todo.toggle("1")
        XCTAssertEqual(todo.items.map(\.done), [false, false])
        todo.toggle("missing")
        XCTAssertEqual(todo.items.map(\.done), [false, false])
    }

    func testAddTrimsAndAppends() {
        Store.backend = MemoryBackend()
        var todo = TodoList()
        todo.add("  شیر بخر \n")
        todo.add("نان")
        XCTAssertEqual(todo.items.map(\.text), ["شیر بخر", "نان"])
        XCTAssertEqual(todo.remaining, 2)
        XCTAssertNotEqual(todo.items[0].id, todo.items[1].id)
    }

    func testAddIgnoresBlankText() {
        Store.backend = MemoryBackend()
        var todo = TodoList()
        todo.add("")
        todo.add("   \n ")
        XCTAssertTrue(todo.items.isEmpty)
    }

    func testClearDoneKeepsOpenEntriesInOrder() {
        Store.backend = MemoryBackend()
        var todo = list([true, false, true, false])
        todo.clearDone()
        XCTAssertEqual(todo.items.map(\.id), ["1", "3"])
        XCTAssertEqual(todo.doneCount, 0)
    }
}
