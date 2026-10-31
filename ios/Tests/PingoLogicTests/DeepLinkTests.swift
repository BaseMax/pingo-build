import XCTest
@testable import PingoLogic

final class DeepLinkTests: XCTestCase {
    private func url(_ text: String) -> URL {
        URL(string: text) ?? URL(fileURLWithPath: "/")
    }

    private var everyRoute: [Route] {
        var routes: [Route] = [.settings, .library(nil), .guide(nil)]
        routes += PingoKind.allCases.map { Route.kind($0) }
        routes += PingoKind.allCases.map { Route.guide($0) }
        routes += LibraryKind.allCases.map { Route.library($0) }
        routes += LibraryKind.allCases.map { Route.item(ItemRoute(kind: $0, id: UUID().uuidString)) }
        return routes
    }

    func testRoundTripForEveryRouteShape() {
        for route in everyRoute {
            XCTAssertEqual(Route(url: route.url), route, route.url.absoluteString)
        }
    }

    func testExactURLGrammar() {
        XCTAssertEqual(Route.kind(.habit).url.absoluteString, "pingo://kind/habit")
        XCTAssertEqual(Route.item(ItemRoute(kind: .countdown, id: "abc")).url.absoluteString, "pingo://item/countdown/abc")
        XCTAssertEqual(Route.library(nil).url.absoluteString, "pingo://library")
        XCTAssertEqual(Route.library(.album).url.absoluteString, "pingo://library/album")
        XCTAssertEqual(Route.settings.url.absoluteString, "pingo://settings")
        XCTAssertEqual(Route.guide(nil).url.absoluteString, "pingo://guide")
        XCTAssertEqual(Route.guide(.fal).url.absoluteString, "pingo://guide/fal")
    }

    func testParsesHandWrittenURLs() {
        XCTAssertEqual(Route(url: url("pingo://kind/moon")), .kind(.moon))
        XCTAssertEqual(Route(url: url("pingo://item/note/42")), .item(ItemRoute(kind: .note, id: "42")))
        XCTAssertEqual(Route(url: url("pingo://library")), .library(nil))
        XCTAssertEqual(Route(url: url("pingo://library/todo")), .library(.todo))
        XCTAssertEqual(Route(url: url("pingo://settings")), .settings)
        XCTAssertEqual(Route(url: url("pingo://guide/clock")), .guide(.clock))
    }

    func testIdsWithSpecialCharactersRoundTrip() {
        for id in ["a b", "x/y", "q?r#s", "تست", "100%"] {
            let route = Route.item(ItemRoute(kind: .habit, id: id))
            XCTAssertEqual(Route(url: route.url), route, id)
        }
    }

    func testRejectsWrongScheme() {
        XCTAssertNil(Route(url: url("https://kind/date")))
        XCTAssertNil(Route(url: url("pingo2://settings")))
        XCTAssertNil(Route(url: url("widget://settings")))
    }

    func testRejectsUnknownHost() {
        XCTAssertNil(Route(url: url("pingo://home")))
        XCTAssertNil(Route(url: url("pingo://kinds/date")))
    }

    func testRejectsUnknownKinds() {
        XCTAssertNil(Route(url: url("pingo://kind/unknown")))
        XCTAssertNil(Route(url: url("pingo://item/unknown/42")))
        XCTAssertNil(Route(url: url("pingo://item/date/42")))
        XCTAssertNil(Route(url: url("pingo://library/date")))
        XCTAssertNil(Route(url: url("pingo://guide/unknown")))
    }

    func testRejectsEmptyIdsAndMissingParts() {
        XCTAssertNil(Route(url: url("pingo://item/note/")))
        XCTAssertNil(Route(url: url("pingo://item/note")))
        XCTAssertNil(Route(url: url("pingo://item")))
        XCTAssertNil(Route(url: url("pingo://kind")))
        XCTAssertNil(Route(url: url("pingo://kind/")))
    }

    func testRejectsExtraPathParts() {
        XCTAssertNil(Route(url: url("pingo://settings/extra")))
        XCTAssertNil(Route(url: url("pingo://kind/date/extra")))
        XCTAssertNil(Route(url: url("pingo://item/note/1/2")))
        XCTAssertNil(Route(url: url("pingo://library/note/extra")))
        XCTAssertNil(Route(url: url("pingo://guide/date/extra")))
    }
}
