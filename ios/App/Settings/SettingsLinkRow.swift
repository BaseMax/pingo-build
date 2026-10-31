import SwiftUI

struct SettingsLinkRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            LiquidRow(title: title, subtitle: subtitle) {
                RowSymbolTile(symbol: symbol)
            } trailing: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.secondary.opacity(0.7))
            }
        }
        .buttonStyle(Pressable())
    }
}
