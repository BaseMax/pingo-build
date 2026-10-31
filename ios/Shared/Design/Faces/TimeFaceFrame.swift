import SwiftUI

extension CardSize {
    var timeContent: CGSize {
        CGSize(width: points.width - 32, height: points.height - 32)
    }
}

extension View {
    func timeFaceFrame(_ size: CardSize, alignment: Alignment = .center) -> some View {
        padding(16)
            .fitsDesign(size.points, alignment: alignment)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
