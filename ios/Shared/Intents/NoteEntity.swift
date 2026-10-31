import AppIntents
import Foundation

struct NoteEntity: AppEntity, Identifiable {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "یادداشت")
    static let defaultQuery = NoteQuery()

    let id: String
    let title: String
    let subtitle: String
    let symbol: String

    init(_ item: NoteItem) {
        id = item.id
        title = EntityCard.noteTitle(item.text)
        subtitle = "آخرین ویرایش " + Persian.shortDate(item.updated)
        symbol = LibraryKind.note.symbol
    }

    var displayRepresentation: DisplayRepresentation {
        EntityCard.representation(title: title, subtitle: subtitle, symbol: symbol)
    }
}

struct NoteQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [NoteEntity] {
        EntityPicker.pick(identifiers, from: Store.notes.all).map(NoteEntity.init)
    }

    func suggestedEntities() async throws -> [NoteEntity] {
        Store.notes.all.map(NoteEntity.init)
    }

    func defaultResult() async -> NoteEntity? {
        Store.notes.all.first.map(NoteEntity.init)
    }
}
