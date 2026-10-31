import SwiftUI

struct SettingsGroup<Content: View>: View {
    private let title: String
    private let symbol: String
    private let content: Content

    init(_ title: String, symbol: String, @ViewBuilder _ content: () -> Content) {
        self.title = title
        self.symbol = symbol
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title, symbol: symbol)
            content
        }
    }
}
