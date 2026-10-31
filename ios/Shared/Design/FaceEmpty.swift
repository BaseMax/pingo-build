import SwiftUI

struct FaceEmpty: View {
    let symbol: String
    let title: String
    let palette: FacePalette

    init(symbol: String, title: String, palette: FacePalette) {
        self.symbol = symbol
        self.title = title
        self.palette = palette
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 30))
                .foregroundStyle(palette.accent)
                .faceAccent()
            Text(title)
                .dasto(14)
                .foregroundStyle(palette.soft)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
