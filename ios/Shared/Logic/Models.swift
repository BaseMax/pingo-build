import Foundation

enum Appearance: String, Codable, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "خودکار"
        case .light: "روشن"
        case .dark: "تاریک"
        }
    }
}

struct NoteItem: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var text: String = ""
    var theme: Theme? = nil
    var updated: Date = .now
}

struct CountdownItem: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var date: Date = .now
    var symbol: String = "star.fill"
    var theme: Theme? = nil
}

struct HabitItem: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var symbol: String = "flame.fill"
    var days: Set<String> = []
    var theme: Theme? = nil
}

struct TodoEntry: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var text: String = ""
    var done: Bool = false
}

struct TodoList: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var items: [TodoEntry] = []
    var theme: Theme? = nil
}

struct CounterItem: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var symbol: String = "drop.fill"
    var goal: Int = 8
    var step: Int = 1
    var dailyReset: Bool = true
    var counts: [String: Int] = [:]
    var theme: Theme? = nil
}

struct AlbumItem: Codable, Hashable, Identifiable {
    var id: String = UUID().uuidString
    var title: String = ""
    var photos: [String] = []
    var minutes: Int = 60
    var showsTitle: Bool = false
    var theme: Theme? = nil
}

struct AppSettings: Codable, Equatable {
    var haptics: Bool = true
    var appearance: Appearance = .system
    var reminders: Bool = true
    var onboarded: Bool = false
    var seeded: Bool = false
    var showsGregorian: Bool = true
    var kindThemes: [String: Theme] = [:]
    var falSeed: Int = 0

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        haptics = try c.decodeIfPresent(Bool.self, forKey: .haptics) ?? true
        appearance = try c.decodeIfPresent(Appearance.self, forKey: .appearance) ?? .system
        reminders = try c.decodeIfPresent(Bool.self, forKey: .reminders) ?? true
        onboarded = try c.decodeIfPresent(Bool.self, forKey: .onboarded) ?? false
        seeded = try c.decodeIfPresent(Bool.self, forKey: .seeded) ?? false
        showsGregorian = try c.decodeIfPresent(Bool.self, forKey: .showsGregorian) ?? true
        kindThemes = try c.decodeIfPresent([String: Theme].self, forKey: .kindThemes) ?? [:]
        falSeed = try c.decodeIfPresent(Int.self, forKey: .falSeed) ?? 0
    }
}

enum Presets {
    static let countdownSymbols = ["star.fill", "airplane", "gift.fill", "heart.fill", "graduationcap.fill", "party.popper.fill", "briefcase.fill", "house.fill", "cart.fill", "sparkles", "flag.checkered", "figure.run"]
    static let habitSymbols = ["flame.fill", "dumbbell.fill", "book.fill", "drop.fill", "moon.zzz.fill", "figure.walk", "leaf.fill", "pills.fill", "fork.knife", "pencil.and.outline", "music.note", "brain.head.profile"]
    static let counterSymbols = ["drop.fill", "plus.circle.fill", "cup.and.saucer.fill", "leaf.fill", "bolt.fill", "hands.sparkles.fill", "figure.walk", "book.fill", "heart.fill", "star.fill", "pills.fill", "fork.knife"]
    static let albumIntervals: [(minutes: Int, title: String)] = [(15, "هر ۱۵ دقیقه"), (30, "هر نیم ساعت"), (60, "هر ساعت"), (180, "هر سه ساعت"), (1440, "روزانه")]
}
