import AppIntents
import Foundation

struct TodoEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "فهرست کار")
    static let defaultQuery = TodoQuery()

    let id: String
    let title: String
    let subtitle: String
    let symbol: String

    init(_ item: TodoList) {
        id = item.id
        title = EntityCard.title(item.title, fallback: .todo)
        subtitle = item.remaining == 0 ? "همه کارها انجام شده" : Persian.number(item.remaining) + " کار مونده"
        symbol = LibraryKind.todo.symbol
    }

    var displayRepresentation: DisplayRepresentation {
        EntityCard.representation(title: title, subtitle: subtitle, symbol: symbol)
    }
}

struct TodoQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [TodoEntity] {
        EntityPicker.pick(identifiers, from: Store.todos.all).map(TodoEntity.init)
    }

    func suggestedEntities() async throws -> [TodoEntity] {
        Store.todos.all.map(TodoEntity.init)
    }

    func defaultResult() async -> TodoEntity? {
        Store.todos.all.first.map(TodoEntity.init)
    }
}
