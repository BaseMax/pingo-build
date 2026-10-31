import SwiftUI

extension View {
    func libraryRow(top: CGFloat = 5, bottom: CGFloat = 5) -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: top, leading: Layout.gutter, bottom: bottom, trailing: Layout.gutter))
    }
}

extension LibraryKind {
    var libraryTint: Color {
        switch self {
        case .note: Color(hex: 0xFFB020)
        case .countdown: Color(hex: 0xAF52DE)
        case .habit: Color.signal
        case .todo: Color.ocean
        case .counter: Color.leaf
        case .album: Color(hex: 0xFF2D55)
        }
    }
}
