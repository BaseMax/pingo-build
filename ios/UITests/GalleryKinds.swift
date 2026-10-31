import XCTest

struct GalleryKind {
    let raw: String
    let title: String
    let showsLower: Bool
    let showsInk: Bool

    static let timeKinds = [
        GalleryKind(raw: "date", title: "تقویم شمسی", showsLower: true, showsInk: true),
        GalleryKind(raw: "clock", title: "ساعت", showsLower: false, showsInk: false),
        GalleryKind(raw: "progress", title: "پیشرفت زمان", showsLower: false, showsInk: false),
        GalleryKind(raw: "countdown", title: "شمارش معکوس", showsLower: false, showsInk: false),
        GalleryKind(raw: "moon", title: "ماه", showsLower: false, showsInk: false)
    ]

    static let otherKinds = [
        GalleryKind(raw: "note", title: "یادداشت", showsLower: false, showsInk: false),
        GalleryKind(raw: "todo", title: "فهرست کارها", showsLower: false, showsInk: false),
        GalleryKind(raw: "habit", title: "زنجیره عادت", showsLower: true, showsInk: true),
        GalleryKind(raw: "counter", title: "شمارنده", showsLower: false, showsInk: false),
        GalleryKind(raw: "photo", title: "قاب عکس", showsLower: false, showsInk: false),
        GalleryKind(raw: "fal", title: "فال حافظ", showsLower: false, showsInk: false)
    ]
}

class GallerySmokeCase: SmokeCase {
    private let sizes = [("small", "کوچک"), ("medium", "متوسط"), ("large", "بزرگ")]

    override func setUp() {
        super.setUp()
        finishOnboardingIfShown()
    }

    func visit(_ kinds: [GalleryKind]) {
        for kind in kinds { open(kind) }
    }

    private func open(_ kind: GalleryKind) {
        let card = button(kind.title)
        guard reveal(card) else {
            miss("gallery card " + kind.title)
            return
        }
        press(card)
        snap("kind-" + kind.raw + "-default", wait: 1.2)
        for (raw, title) in sizes where button(title).exists {
            press(button(title))
            snap("kind-" + kind.raw + "-" + raw, wait: 0.8)
        }
        if kind.showsLower { lower(kind) }
        if kind.showsInk { ink(kind) }
        goBack()
        ensureAlive("back from " + kind.raw)
    }

    private func lower(_ kind: GalleryKind) {
        scrollDown(2)
        snap("kind-" + kind.raw + "-lower")
    }

    private func ink(_ kind: GalleryKind) {
        let swatch = button("جوهر")
        guard swatchReachable(swatch) else {
            miss("theme ink for " + kind.raw)
            return
        }
        press(swatch)
        scrollTop()
        snap("kind-" + kind.raw + "-theme-ink")
    }

    private func swatchReachable(_ swatch: XCUIElement) -> Bool {
        let anchor = button("کاغذی")
        if swatch.exists, swatch.isHittable { return true }
        guard anchor.exists else { return false }
        for index in 0..<4 {
            if index.isMultiple(of: 2) { anchor.swipeLeft() } else { anchor.swipeRight() }
            if swatch.exists, swatch.isHittable { return true }
        }
        return false
    }
}

final class S03GalleryTimeSmokeTests: GallerySmokeCase {
    func testTimeKinds() { visit(GalleryKind.timeKinds) }
}

final class S03GalleryOtherSmokeTests: GallerySmokeCase {
    func testOtherKinds() { visit(GalleryKind.otherKinds) }
}
