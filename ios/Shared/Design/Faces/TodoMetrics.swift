import SwiftUI

struct TodoMetrics {
    let limit: Int
    let rowHeight: CGFloat
    let rowSpacing: CGFloat
    let textSize: CGFloat
    let box: CGFloat

    static func make(_ size: CardSize) -> TodoMetrics {
        switch size {
        case .small: TodoMetrics(limit: 3, rowHeight: 22, rowSpacing: 4, textSize: 13, box: 18)
        case .medium: TodoMetrics(limit: 4, rowHeight: 26, rowSpacing: 4, textSize: 15, box: 21)
        case .large: TodoMetrics(limit: 9, rowHeight: 25, rowSpacing: 4, textSize: 16, box: 22)
        }
    }
}

extension TodoList {
    func faceEntries(limit: Int) -> [TodoEntry] {
        let ordered = items.filter { !$0.done } + items.filter(\.done)
        return Array(ordered.prefix(limit))
    }
}
