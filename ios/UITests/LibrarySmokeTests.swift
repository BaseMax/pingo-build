import XCTest

final class S04LibrarySmokeTests: SmokeCase {
    private let kinds: [(raw: String, title: String)] = [
        ("note", "یادداشت"),
        ("countdown", "شمارش معکوس"),
        ("habit", "عادت"),
        ("todo", "فهرست کار"),
        ("counter", "شمارنده"),
        ("album", "آلبوم")
    ]

    override func setUp() {
        super.setUp()
        finishOnboardingIfShown()
        openTab(Labels.library)
    }

    func testLibraryAndEditors() {
        snap("library-seeded")
        scrollDown(2)
        snap("library-seeded-scrolled")
        scrollTop()
        if tap("افزودن") {
            snap("library-add-menu-open", wait: 1)
            tap("بستن")
        }
        for kind in kinds { create(kind) }
        snap("library-after-creating", wait: 1)
    }

    private func create(_ kind: (raw: String, title: String)) {
        guard tap("افزودن") else { return }
        settle(0.6)
        guard tap(kind.title) else { return }
        snap("editor-" + kind.raw + "-new", wait: 1.2)
        interact(kind.raw)
        goBack()
        ensureAlive("editor " + kind.raw)
    }

    private func interact(_ raw: String) {
        switch raw {
        case "note": typeIfPossible("Remember the milk", into: app.textViews.firstMatch)
        case "habit": toggleHabit()
        case "todo": addTodo()
        case "counter": stepCounter()
        default: break
        }
        if raw == "note" { snap("editor-note-typed") }
    }

    private func toggleHabit() {
        tap("ثبت امروز")
        snap("editor-habit-done", wait: 1)
        scrollDown(2)
        snap("editor-habit-lower")
        scrollTop()
        tap("امروز ثبت شد، لغو")
        snap("editor-habit-undone", wait: 1)
    }

    private func addTodo() {
        typeIfPossible("Buy bread", into: app.textFields.firstMatch)
        tap("اضافه کن", timeout: 1.5)
        tap("انجام شد", timeout: 1.5)
        snap("editor-todo-edited", wait: 1)
    }

    private func stepCounter() {
        for _ in 0..<3 { tap("اضافه کن", timeout: 1.5) }
        snap("editor-counter-plus", wait: 1)
        tap("کم کن", timeout: 1.5)
        snap("editor-counter-minus", wait: 1)
    }
}
