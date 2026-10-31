import AppIntents
import Foundation

struct CountdownEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "شمارش معکوس")
    static let defaultQuery = CountdownQuery()

    let id: String
    let title: String
    let subtitle: String
    let symbol: String

    init(_ item: CountdownItem) {
        id = item.id
        title = EntityCard.title(item.title, fallback: .countdown)
        subtitle = Persian.shortDate(item.date) + "، " + Persian.relativeDay(item.date)
        symbol = item.symbol
    }

    var displayRepresentation: DisplayRepresentation {
        EntityCard.representation(title: title, subtitle: subtitle, symbol: symbol)
    }
}

struct CountdownQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CountdownEntity] {
        EntityPicker.pick(identifiers, from: Store.countdowns.all).map(CountdownEntity.init)
    }

    func suggestedEntities() async throws -> [CountdownEntity] {
        Store.countdowns.all.map(CountdownEntity.init)
    }

    func defaultResult() async -> CountdownEntity? {
        Store.countdowns.all.first.map(CountdownEntity.init)
    }
}
