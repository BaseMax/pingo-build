import XCTest
@testable import PingoLogic

final class FaceNoticeTests: XCTestCase {
    override func setUp() {
        Store.backend = MemoryBackend()
    }

    func testTimeKindsNeverNeedANotice() {
        for kind in [PingoKind.date, .clock, .progress, .moon, .fal] {
            XCTAssertNil(kind.notice(selection: WidgetSelection(itemID: "x"), groupUnreachable: true))
        }
    }

    func testUnreachableGroupAffectsKindsWithData() {
        for kind in PingoKind.allCases where kind.library != nil {
            XCTAssertEqual(kind.notice(selection: WidgetSelection(), groupUnreachable: true), .groupUnreachable)
        }
    }

    func testDeletedItemAsksToChooseAnotherWhenOthersExist() {
        Store.counters.save([CounterItem(id: "a"), CounterItem(id: "b")])
        XCTAssertEqual(PingoKind.counter.notice(selection: WidgetSelection(itemID: "gone"), groupUnreachable: false), .chooseItem)
        XCTAssertNil(PingoKind.counter.notice(selection: WidgetSelection(itemID: "b"), groupUnreachable: false))
        XCTAssertNil(PingoKind.counter.notice(selection: WidgetSelection(), groupUnreachable: false))
    }

    func testNoItemsAtAllKeepsTheFaceOwnEmptyState() {
        XCTAssertNil(PingoKind.habit.notice(selection: WidgetSelection(itemID: "gone"), groupUnreachable: false))
    }

    func testLinkAndResolvedIDForDeletedItem() {
        Store.notes.save([NoteItem(id: "a")])
        XCTAssertNil(PingoKind.note.resolvedItemID(WidgetSelection(itemID: "gone")))
        XCTAssertEqual(PingoKind.note.resolvedItemID(WidgetSelection()), "a")
        XCTAssertNil(PingoKind.moon.resolvedItemID(WidgetSelection()))
    }
}
