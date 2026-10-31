import Foundation

enum FaceNoticeKind: Equatable {
    case groupUnreachable
    case chooseItem
}

extension PingoKind {
    func resolvedItemID(_ selection: WidgetSelection) -> String? {
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

    func notice(selection: WidgetSelection, groupUnreachable: Bool = AppGroup.isUnreachableFromWidget) -> FaceNoticeKind? {
        guard let library else { return nil }
        if groupUnreachable { return .groupUnreachable }
        let lostItem = selection.itemID != nil && resolvedItemID(selection) == nil
        return lostItem && Store.count(of: library) > 0 ? .chooseItem : nil
    }
}
