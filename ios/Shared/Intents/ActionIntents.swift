import AppIntents
import Foundation

struct ToggleHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "ثبت عادت امروز"
    static let isDiscoverable = false

    @Parameter(title: "شناسه عادت") var habitID: String

    init() {}

    init(habitID: String) {
        self.habitID = habitID
    }

    func perform() async throws -> some IntentResult {
        Store.habits.update(habitID) { $0.toggle(.now) }
        return .result()
    }
}

struct CounterStepIntent: AppIntent {
    static let title: LocalizedStringResource = "تغییر شمارنده"
    static let isDiscoverable = false

    @Parameter(title: "شناسه شمارنده") var counterID: String
    @Parameter(title: "مقدار") var delta: Int

    init() {}

    init(counterID: String, delta: Int) {
        self.counterID = counterID
        self.delta = delta
    }

    func perform() async throws -> some IntentResult {
        let change = delta
        Store.counters.update(counterID) { counter in
            let amount = change * counter.step
            counter.step(by: amount, on: .now)
        }
        return .result()
    }
}

struct ToggleTodoIntent: AppIntent {
    static let title: LocalizedStringResource = "تیک زدن کار"
    static let isDiscoverable = false

    @Parameter(title: "شناسه فهرست") var listID: String
    @Parameter(title: "شناسه کار") var itemID: String

    init() {}

    init(listID: String, itemID: String) {
        self.listID = listID
        self.itemID = itemID
    }

    func perform() async throws -> some IntentResult {
        let entry = itemID
        Store.todos.update(listID) { $0.toggle(entry) }
        return .result()
    }
}

struct NewFalIntent: AppIntent {
    static let title: LocalizedStringResource = "فال جدید"
    static let isDiscoverable = false

    init() {}

    func perform() async throws -> some IntentResult {
        Store.settings.falSeed += 1
        return .result()
    }
}

struct ToggleFirstHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "ثبت اولین عادت"
    static let isDiscoverable = false

    init() {}

    func perform() async throws -> some IntentResult {
        guard let id = Store.habits.all.first?.id else { return .result() }
        Store.habits.update(id) { $0.toggle(.now) }
        return .result()
    }
}

struct CountFirstCounterIntent: AppIntent {
    static let title: LocalizedStringResource = "یکی اضافه کن"
    static let isDiscoverable = false

    init() {}

    func perform() async throws -> some IntentResult {
        guard let first = Store.counters.all.first else { return .result() }
        Store.counters.update(first.id) { counter in
            counter.step(by: counter.step, on: .now)
        }
        return .result()
    }
}
