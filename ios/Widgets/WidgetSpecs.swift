import WidgetKit

enum DateSpec: WidgetSpec {
    typealias Config = ThemeConfigIntent
    static let kind = PingoKind.date
}

enum ClockSpec: WidgetSpec {
    typealias Config = ThemeConfigIntent
    static let kind = PingoKind.clock
}

enum ProgressSpec: WidgetSpec {
    typealias Config = ThemeConfigIntent
    static let kind = PingoKind.progress
}

enum CountdownSpec: WidgetSpec {
    typealias Config = CountdownConfigIntent
    static let kind = PingoKind.countdown
}

enum MoonSpec: WidgetSpec {
    typealias Config = ThemeConfigIntent
    static let kind = PingoKind.moon
}

enum NoteSpec: WidgetSpec {
    typealias Config = NoteConfigIntent
    static let kind = PingoKind.note
}

enum TodoSpec: WidgetSpec {
    typealias Config = TodoConfigIntent
    static let kind = PingoKind.todo
}

enum HabitSpec: WidgetSpec {
    typealias Config = HabitConfigIntent
    static let kind = PingoKind.habit
}

enum CounterSpec: WidgetSpec {
    typealias Config = CounterConfigIntent
    static let kind = PingoKind.counter
}

enum PhotoSpec: WidgetSpec {
    typealias Config = AlbumConfigIntent
    static let kind = PingoKind.photo
}

enum FalSpec: WidgetSpec {
    typealias Config = ThemeConfigIntent
    static let kind = PingoKind.fal
}
