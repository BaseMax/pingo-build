import SwiftUI

struct KindOptions: View {
    let kind: PingoKind

    @State private var live = LiveSettings.shared

    static func applies(to kind: PingoKind) -> Bool {
        kind == .date
    }

    var body: some View {
        switch kind {
        case .date:
            LiquidToggleRow("نمایش تاریخ میلادی", symbol: "globe", isOn: gregorian)
        default:
            EmptyView()
        }
    }

    private var gregorian: Binding<Bool> {
        Binding(
            get: { live.value.showsGregorian },
            set: { live.value.showsGregorian = $0 }
        )
    }
}

enum KindSuccess {
    static func isReached(_ kind: PingoKind, on date: Date = .now) -> Bool {
        let first = WidgetSelection()
        switch kind {
        case .habit:
            return Store.habits.resolve(first)?.isDone(date) ?? false
        case .counter:
            return Store.counters.resolve(first)?.reachedGoal(on: date) ?? false
        case .todo:
            return Store.todos.resolve(first).map { !$0.items.isEmpty && $0.remaining == 0 } ?? false
        default:
            return false
        }
    }
}
