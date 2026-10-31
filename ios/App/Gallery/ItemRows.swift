import Foundation

struct ItemRowModel: Identifiable {
    let id: String
    let title: String
    let subtitle: String?
}

enum ItemRows {
    static func note(_ item: NoteItem) -> ItemRowModel {
        let firstLine = item.text.split(whereSeparator: \.isNewline).first.map(String.init)
        return ItemRowModel(id: item.id, title: firstLine ?? "یادداشت خالی", subtitle: Persian.shortDate(item.updated))
    }

    static func countdown(_ item: CountdownItem) -> ItemRowModel {
        ItemRowModel(id: item.id, title: named(item.title), subtitle: Persian.relativeDay(item.date))
    }

    static func habit(_ item: HabitItem) -> ItemRowModel {
        let streak = Persian.number(item.streak(asOf: .now))
        return ItemRowModel(id: item.id, title: named(item.title), subtitle: "زنجیره " + streak + " روزه")
    }

    static func todo(_ item: TodoList) -> ItemRowModel {
        let done = Persian.number(item.doneCount)
        let total = Persian.number(item.items.count)
        return ItemRowModel(id: item.id, title: named(item.title), subtitle: done + " از " + total + " انجام شده")
    }

    static func counter(_ item: CounterItem) -> ItemRowModel {
        let today = Persian.number(item.count(on: .now))
        let goal = Persian.number(item.goal)
        return ItemRowModel(id: item.id, title: named(item.title), subtitle: "امروز " + today + " از " + goal)
    }

    static func album(_ item: AlbumItem) -> ItemRowModel {
        ItemRowModel(id: item.id, title: named(item.title), subtitle: Persian.number(item.photos.count) + " عکس")
    }

    private static func named(_ title: String) -> String {
        title.isEmpty ? "بدون عنوان" : title
    }
}
