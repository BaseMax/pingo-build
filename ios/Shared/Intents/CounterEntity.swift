import AppIntents
import Foundation

struct CounterEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "شمارنده")
    static let defaultQuery = CounterQuery()

    let id: String
    let title: String
    let subtitle: String
    let symbol: String

    init(_ item: CounterItem) {
        id = item.id
        title = EntityCard.title(item.title, fallback: .counter)
        subtitle = "هدف " + Persian.number(item.goal)
        symbol = item.symbol
    }

    var displayRepresentation: DisplayRepresentation {
        EntityCard.representation(title: title, subtitle: subtitle, symbol: symbol)
    }
}

struct CounterQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CounterEntity] {
        EntityPicker.pick(identifiers, from: Store.counters.all).map(CounterEntity.init)
    }

    func suggestedEntities() async throws -> [CounterEntity] {
        Store.counters.all.map(CounterEntity.init)
    }

    func defaultResult() async -> CounterEntity? {
        Store.counters.all.first.map(CounterEntity.init)
    }
}
