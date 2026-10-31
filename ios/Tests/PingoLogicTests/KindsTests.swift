import XCTest
@testable import PingoLogic

final class KindsTests: XCTestCase {
    private let accessoryKinds: Set<PingoKind> = [.date, .clock, .progress, .countdown, .moon, .habit, .counter]

    func testElevenKindsWithUniqueRawValues() {
        XCTAssertEqual(PingoKind.allCases.count, 11)
        XCTAssertEqual(Set(PingoKind.allCases.map(\.rawValue)).count, 11)
        XCTAssertEqual(PingoKind.date.id, "date")
    }

    func testEveryKindHasTextSymbolAndSizes() {
        for kind in PingoKind.allCases {
            XCTAssertFalse(kind.title.isEmpty, kind.rawValue)
            XCTAssertFalse(kind.about.isEmpty, kind.rawValue)
            XCTAssertFalse(kind.symbol.isEmpty, kind.rawValue)
            XCTAssertFalse(kind.sizes.isEmpty, kind.rawValue)
            XCTAssertEqual(Set(kind.sizes).count, kind.sizes.count, kind.rawValue)
        }
        XCTAssertEqual(Set(PingoKind.allCases.map(\.title)).count, 11)
    }

    func testAccessoriesOnlyForListedKinds() {
        for kind in PingoKind.allCases {
            XCTAssertEqual(!kind.accessories.isEmpty, accessoryKinds.contains(kind), kind.rawValue)
            XCTAssertEqual(Set(kind.accessories).count, kind.accessories.count, kind.rawValue)
        }
    }

    func testFalOnlyOffersMediumAndLarge() {
        XCTAssertEqual(PingoKind.fal.sizes, [.medium, .large])
        XCTAssertEqual(PingoKind.clock.sizes, [.small, .medium])
        XCTAssertEqual(PingoKind.photo.sizes, CardSize.allCases)
    }

    func testInteractiveKinds() {
        let interactive = Set(PingoKind.allCases.filter(\.isInteractive))
        XCTAssertEqual(interactive, [.todo, .habit, .counter, .fal])
    }

    func testOnlyPhotoUsesPhotos() {
        XCTAssertEqual(PingoKind.allCases.filter(\.usesPhotos), [.photo])
    }

    func testLibraryMappingIsConsistent() {
        for library in LibraryKind.allCases {
            XCTAssertEqual(library.widget.library, library, library.rawValue)
            XCTAssertFalse(library.title.isEmpty)
            XCTAssertFalse(library.plural.isEmpty)
            XCTAssertFalse(library.symbol.isEmpty)
        }
        for kind in PingoKind.allCases {
            if let library = kind.library {
                XCTAssertEqual(library.widget, kind)
            }
        }
    }

    func testEveryLibraryKindBacksExactlyOneWidget() {
        for library in LibraryKind.allCases {
            XCTAssertEqual(PingoKind.allCases.filter { $0.library == library }.count, 1, library.rawValue)
        }
        XCTAssertEqual(PingoKind.allCases.filter { $0.library == nil }, [.date, .clock, .progress, .moon, .fal])
    }

    func testCategoriesCoverEveryKind() {
        for category in PingoCategory.allCases {
            XCTAssertFalse(PingoKind.allCases.filter { $0.category == category }.isEmpty, category.rawValue)
            XCTAssertFalse(category.title.isEmpty)
            XCTAssertFalse(category.symbol.isEmpty)
        }
        XCTAssertEqual(PingoKind.photo.category, .inspire)
        XCTAssertEqual(PingoKind.clock.category, .time)
        XCTAssertEqual(PingoKind.habit.category, .tasks)
    }

    func testThemeBasics() {
        XCTAssertEqual(Theme.allCases.count, 7)
        XCTAssertEqual(Set(Theme.allCases.map(\.title)).count, 7)
        XCTAssertTrue(Theme.allCases.allSatisfy { $0.id == $0.rawValue && !$0.title.isEmpty })
        XCTAssertEqual(Set(Theme.allCases.filter(\.isLight)), [.paper, .haze, .sand])
    }

    func testThemeCodableRoundTrip() throws {
        for theme in Theme.allCases {
            let data = try JSONEncoder().encode([theme])
            XCTAssertEqual(try JSONDecoder().decode([Theme].self, from: data), [theme])
        }
    }

    func testEveryKindHasADefaultTheme() {
        for kind in PingoKind.allCases {
            XCTAssertTrue(Theme.allCases.contains(kind.defaultTheme))
        }
        XCTAssertEqual(PingoKind.habit.defaultTheme, .leaf)
    }

    func testCardSizesAndShapesHaveTitlesAndGrowingPoints() {
        XCTAssertTrue(CardSize.allCases.allSatisfy { !$0.title.isEmpty })
        XCTAssertTrue(AccessoryShape.allCases.allSatisfy { !$0.title.isEmpty })
        XCTAssertEqual(CardSize.small.points.width, CardSize.small.points.height)
        XCTAssertEqual(CardSize.medium.points.width, CardSize.large.points.width)
        XCTAssertTrue(CardSize.large.points.height > CardSize.medium.points.height)
    }
}
