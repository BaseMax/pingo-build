import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

extension Notification.Name {
    static let pingoStoreChanged = Notification.Name("pingoStoreChanged")
}

enum Store {
    static var backend: KeyValueBackend = makeBackend()
    static var onChange: (PingoKind?) -> Void = broadcast

    static let notes = ItemStore<NoteItem>(key: "notes", kind: LibraryKind.note.widget)
    static let countdowns = ItemStore<CountdownItem>(key: "countdowns", kind: LibraryKind.countdown.widget)
    static let habits = ItemStore<HabitItem>(key: "habits", kind: LibraryKind.habit.widget)
    static let todos = ItemStore<TodoList>(key: "todos", kind: LibraryKind.todo.widget)
    static let counters = ItemStore<CounterItem>(key: "counters", kind: LibraryKind.counter.widget)
    static let albums = ItemStore<AlbumItem>(key: "albums", kind: LibraryKind.album.widget)

    private static let settingsKey = "settings"

    static var settings: AppSettings {
        get {
            guard let data = backend.data(for: settingsKey) else { return AppSettings() }
            return (try? JSONCoding.decoder().decode(AppSettings.self, from: data)) ?? AppSettings()
        }
        set {
            persist(newValue)
            touch(nil)
        }
    }

    static func theme(for kind: PingoKind) -> Theme {
        settings.kindThemes[kind.rawValue] ?? kind.defaultTheme
    }

    static func theme(for kind: PingoKind, selection: WidgetSelection) -> Theme {
        selection.theme ?? itemTheme(for: kind, selection: selection) ?? theme(for: kind)
    }

    static func setTheme(_ theme: Theme, for kind: PingoKind) {
        var current = settings
        current.kindThemes[kind.rawValue] = theme
        persist(current)
        touch(kind)
    }

    static func touch(_ kind: PingoKind?) {
        onChange(kind)
    }

    static func create(_ kind: LibraryKind) -> String {
        switch kind {
        case .note: return append(NoteItem(), to: notes)
        case .countdown: return append(CountdownItem(title: "رویداد جدید", date: daysAhead(30)), to: countdowns)
        case .habit: return append(HabitItem(title: "عادت جدید"), to: habits)
        case .todo: return append(TodoList(title: "فهرست جدید"), to: todos)
        case .counter: return append(CounterItem(title: "شمارنده جدید"), to: counters)
        case .album: return append(AlbumItem(title: "آلبوم جدید"), to: albums)
        }
    }

    static func count(of kind: LibraryKind) -> Int {
        switch kind {
        case .note: notes.all.count
        case .countdown: countdowns.all.count
        case .habit: habits.all.count
        case .todo: todos.all.count
        case .counter: counters.all.count
        case .album: albums.all.count
        }
    }

    static func prepare() {
        var current = settings
        guard !current.seeded, LibraryKind.allCases.allSatisfy({ count(of: $0) == 0 }) else { return }
        notes.write([NoteItem(text: "امروز چه کاری از همه مهم‌تره؟")])
        countdowns.write([CountdownItem(title: "سفر بعدی", date: daysAhead(30), symbol: "airplane")])
        habits.write([HabitItem(title: "ورزش", symbol: "dumbbell.fill")])
        todos.write([sampleTodo()])
        counters.write([CounterItem(title: "آب", goal: 8)])
        current.seeded = true
        settings = current
    }

    private static func sampleTodo() -> TodoList {
        var list = TodoList(title: "کارهای امروز")
        for text in ["یه لیوان آب بخور", "ده دقیقه قدم بزن", "ویجت‌های پینگو رو امتحان کن"] {
            list.add(text)
        }
        return list
    }

    private static func daysAhead(_ days: Int) -> Date {
        Persian.calendar.startOfDay(for: Persian.shift(.now, days: days))
    }

    private static func append<Item: Codable & Identifiable & Hashable>(_ item: Item, to store: ItemStore<Item>) -> String where Item.ID == String {
        store.add(item)
        return item.id
    }

    private static func itemTheme(for kind: PingoKind, selection: WidgetSelection) -> Theme? {
        switch kind.library {
        case .note: notes.resolve(selection)?.theme
        case .countdown: countdowns.resolve(selection)?.theme
        case .habit: habits.resolve(selection)?.theme
        case .todo: todos.resolve(selection)?.theme
        case .counter: counters.resolve(selection)?.theme
        case .album: albums.resolve(selection)?.theme
        case nil: nil
        }
    }

    private static func persist(_ value: AppSettings) {
        guard let data = try? JSONCoding.encoder().encode(value) else { return }
        backend.set(data, for: settingsKey)
    }

    private static func makeBackend() -> KeyValueBackend {
        #if canImport(WidgetKit)
        DefaultsBackend(AppGroup.defaults)
        #else
        MemoryBackend()
        #endif
    }

    private static func broadcast(_ kind: PingoKind?) {
        #if canImport(WidgetKit)
        if let kind {
            WidgetCenter.shared.reloadTimelines(ofKind: kind.rawValue)
        } else {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
        postOnMain()
    }

    private static func postOnMain() {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: .pingoStoreChanged, object: nil)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .pingoStoreChanged, object: nil)
            }
        }
    }
}
