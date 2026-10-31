import SwiftUI

extension View {
    func taskFaceFrame(_ size: CardSize) -> some View {
        padding(16)
            .frame(width: size.points.width, height: size.points.height)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
