import SwiftUI

struct LibrarySymbolTile: View {
    let symbol: String
    let theme: Theme

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
    }

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(theme.isLight ? Color.signal : Color.white)
            .frame(width: 42, height: 42)
            .background {
                LinearGradient(colors: theme.colors, startPoint: .top, endPoint: .bottom)
                    .clipShape(shape)
            }
            .overlay {
                shape.strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
            }
    }
}
