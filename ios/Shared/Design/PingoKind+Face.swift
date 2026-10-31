import SwiftUI

extension PingoKind {
    @ViewBuilder
    func face(size: CardSize, date: Date, selection: WidgetSelection) -> some View {
        faceContent(size: size, date: date, selection: selection)
            .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    func accessoryFace(shape: AccessoryShape, date: Date, selection: WidgetSelection) -> some View {
        accessoryContent(shape: shape, date: date, selection: selection)
            .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    func background(selection: WidgetSelection) -> some View {
        if self == .photo {
            Color.black
        } else {
            Store.theme(for: self, selection: selection).background
        }
    }

    func link(selection: WidgetSelection) -> URL {
        guard let library, let id = resolvedItemID(selection) else {
            return Route.kind(self).url
        }
        return Route.item(ItemRoute(kind: library, id: id)).url
    }

    private func resolvedItemID(_ selection: WidgetSelection) -> String? {
        switch self {
        case .note: Store.notes.resolve(selection)?.id
        case .countdown: Store.countdowns.resolve(selection)?.id
        case .habit: Store.habits.resolve(selection)?.id
        case .todo: Store.todos.resolve(selection)?.id
        case .counter: Store.counters.resolve(selection)?.id
        case .photo: Store.albums.resolve(selection)?.id
        default: nil
        }
    }

    @ViewBuilder
    private func faceContent(size: CardSize, date: Date, selection: WidgetSelection) -> some View {
        let theme = Store.theme(for: self, selection: selection)
        switch self {
        case .date:
            DateFace(date: date, size: size, theme: theme, showsGregorian: Store.settings.showsGregorian)
        case .clock:
            ClockFace(date: date, size: size, theme: theme)
        case .progress:
            ProgressFace(date: date, size: size, theme: theme)
        case .countdown:
            CountdownFace(item: Store.countdowns.resolve(selection), date: date, size: size, theme: theme)
        case .moon:
            MoonFace(phase: MoonPhase(date: date), size: size, theme: theme)
        case .note:
            NoteFace(item: Store.notes.resolve(selection), size: size, theme: theme)
        case .todo:
            TodoFace(list: Store.todos.resolve(selection), size: size, theme: theme)
        case .habit:
            HabitFace(item: Store.habits.resolve(selection), date: date, size: size, theme: theme)
        case .counter:
            CounterFace(item: Store.counters.resolve(selection), date: date, size: size, theme: theme)
        case .photo:
            PhotoFace(album: Store.albums.resolve(selection), date: date, size: size, theme: theme)
        case .fal:
            FalFace(date: date, seed: Store.settings.falSeed, size: size, theme: theme)
        }
    }

    @ViewBuilder
    private func accessoryContent(shape: AccessoryShape, date: Date, selection: WidgetSelection) -> some View {
        switch self {
        case .date:
            DateAccessory(date: date, shape: shape, showsGregorian: Store.settings.showsGregorian)
        case .clock:
            ClockAccessory(date: date)
        case .progress:
            ProgressAccessory(date: date, shape: shape)
        case .countdown:
            CountdownAccessory(item: Store.countdowns.resolve(selection), date: date, shape: shape)
        case .moon:
            MoonAccessory(phase: MoonPhase(date: date))
        case .habit:
            HabitAccessory(item: Store.habits.resolve(selection), date: date)
        case .counter:
            CounterAccessory(item: Store.counters.resolve(selection), date: date)
        default:
            EmptyView()
        }
    }
}
