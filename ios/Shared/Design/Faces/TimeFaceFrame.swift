import SwiftUI

extension CardSize {
    var timeContent: CGSize {
        CGSize(width: points.width - 32, height: points.height - 32)
    }
}

extension View {
    func timeFaceFrame(_ size: CardSize, alignment: Alignment = .center) -> some View {
        padding(16)
            .frame(width: size.points.width, height: size.points.height, alignment: alignment)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
