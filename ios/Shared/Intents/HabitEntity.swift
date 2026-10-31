import AppIntents
import Foundation

struct HabitEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "عادت")
    static let defaultQuery = HabitQuery()

    let id: String
    let title: String
    let subtitle: String
    let symbol: String

    init(_ item: HabitItem) {
        id = item.id
        title = EntityCard.title(item.title, fallback: .habit)
        subtitle = "زنجیره " + Persian.number(item.streak(asOf: .now)) + " روزه"
        symbol = item.symbol
    }

    var displayRepresentation: DisplayRepresentation {
        EntityCard.representation(title: title, subtitle: subtitle, symbol: symbol)
    }
}

struct HabitQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [HabitEntity] {
        EntityPicker.pick(identifiers, from: Store.habits.all).map(HabitEntity.init)
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        Store.habits.all.map(HabitEntity.init)
    }

    func defaultResult() async -> HabitEntity? {
        Store.habits.all.first.map(HabitEntity.init)
    }
}
