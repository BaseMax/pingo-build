import XCTest

final class S05SettingsSmokeTests: SmokeCase {
    override func setUp() {
        super.setUp()
        finishOnboardingIfShown()
        openTab(Labels.settings)
    }

    func testSettingsSections() {
        snap("settings-top")
        scrollDown(1)
        snap("settings-scroll-1")
        scrollDown(2)
        snap("settings-scroll-2")
        scrollDown(2)
        snap("settings-scroll-3")
    }

    func testAppearanceModes() {
        let dark = button("تاریک")
        if reveal(dark) {
            press(dark)
            snap("settings-dark", wait: 1.5)
            openTab(Labels.library)
            snap("library-dark", wait: 1.2)
            openTab(Labels.widgets)
            snap("gallery-dark", wait: 1.2)
            openTab(Labels.settings)
        } else {
            miss("appearance dark segment")
        }
        let light = button("روشن")
        if reveal(light) {
            press(light)
            snap("settings-light", wait: 1.2)
        }
    }

    func testGuideSheetFromSettings() {
        let guideRow = row("راهنمای افزودن ویجت")
        if reveal(guideRow) {
            press(guideRow)
            snap("settings-guide-sheet", wait: 3)
            scrollDown(2)
            snap("settings-guide-sheet-scrolled")
            tap("بستن")
        } else {
            miss("guide row")
        }
    }

    func testBackupSection() {
        let export = row("گرفتن نسخه پشتیبان")
        guard reveal(export) else {
            miss("backup export button")
            return
        }
        snap("settings-backup-section")
        press(export)
        snap("settings-backup-export-sheet", wait: 3)
        dismissSystemSheet()
        let restore = row("بازیابی از نسخه پشتیبان")
        if restore.waitForExistence(timeout: 2), restore.isHittable {
            press(restore)
            snap("settings-backup-import-sheet", wait: 3)
            dismissSystemSheet()
        }
    }

    private func dismissSystemSheet() {
        for label in ["Cancel", "لغو", "Close", "Done"] {
            let candidate = app.buttons[label].firstMatch
            if candidate.waitForExistence(timeout: 1) {
                press(candidate)
                settle(1)
                return
            }
        }
        miss("system sheet cancel button")
        app.terminate()
        app.launch()
        settle(1.5)
    }
}
