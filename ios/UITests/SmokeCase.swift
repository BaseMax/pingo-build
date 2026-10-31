import XCTest

class SmokeCase: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        Shots.prepare()
        addUIInterruptionMonitor(withDescription: "system alert") { alert in
            alert.buttons.firstMatch.tap()
            return true
        }
        if let language = ProcessInfo.processInfo.environment["SMOKE_LANG"], !language.isEmpty {
            app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", language + "_IR"]
        }
        app.launch()
        settle(1)
    }

    func settle(_ seconds: TimeInterval = 0.5) {
        Thread.sleep(forTimeInterval: seconds)
    }

    func snap(_ slug: String, wait: TimeInterval = 0.6) {
        settle(wait)
        Shots.save(slug, in: self)
        ensureAlive(slug)
    }

    @discardableResult
    func ensureAlive(_ context: String) -> Bool {
        guard app.state != .runningForeground else { return true }
        XCTFail("app is not running after \(context), state \(app.state.rawValue)")
        app.launch()
        settle(1.5)
        return false
    }

    func miss(_ what: String) {
        Shots.recordMissing(String(describing: type(of: self)) + " " + name + ": " + what)
    }

    func button(_ label: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    func row(_ prefix: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", prefix)).firstMatch
    }

    func anyElement(_ label: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    func press(_ element: XCUIElement) {
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    @discardableResult
    func tap(_ label: String, timeout: TimeInterval = 3) -> Bool {
        let target = button(label)
        guard target.waitForExistence(timeout: timeout) else {
            miss("button " + label)
            return false
        }
        press(target)
        return true
    }

    @discardableResult
    func tapAny(_ label: String, timeout: TimeInterval = 3) -> Bool {
        let target = anyElement(label)
        guard target.waitForExistence(timeout: timeout) else {
            miss("element " + label)
            return false
        }
        press(target)
        return true
    }

    @discardableResult
    func reveal(_ element: XCUIElement, limit: Int = 8) -> Bool {
        if element.waitForExistence(timeout: 2), element.isHittable { return true }
        for _ in 0..<limit {
            app.swipeUp()
            if element.exists, element.isHittable { return true }
        }
        for _ in 0..<(limit * 2) {
            app.swipeDown()
            if element.exists, element.isHittable { return true }
        }
        return false
    }

    func scrollDown(_ times: Int = 1) {
        for _ in 0..<times { app.swipeUp() }
        settle(0.5)
    }

    func scrollTop() {
        for _ in 0..<6 { app.swipeDown() }
        settle(0.5)
    }

    func goBack() {
        let named = app.navigationBars.buttons["BackButton"]
        let other = app.navigationBars.buttons.matching(NSPredicate(format: "label != %@", "پاک کردن")).element(boundBy: 0)
        if named.exists {
            press(named)
        } else if other.exists {
            press(other)
        } else {
            miss("back button")
        }
        settle(0.8)
    }

    func finishOnboardingIfShown() {
        for _ in 0..<4 {
            let next = button("ادامه")
            let start = button("شروع کن")
            if start.waitForExistence(timeout: 1.5) {
                press(start)
                settle(1)
                return
            }
            guard next.exists else { return }
            press(next)
            settle(0.8)
        }
    }

    func openTab(_ title: String) {
        tap(title)
        settle(0.9)
    }

    func typeIfPossible(_ text: String, into field: XCUIElement) {
        guard field.waitForExistence(timeout: 2) else {
            miss("text input for " + text)
            return
        }
        press(field)
        guard app.keyboards.firstMatch.waitForExistence(timeout: 3) else {
            miss("keyboard for " + text)
            return
        }
        field.typeText(text)
    }
}

enum Labels {
    static let widgets = "ویجت\u{200C}ها"
    static let library = "کتابخانه"
    static let settings = "تنظیمات"
}
