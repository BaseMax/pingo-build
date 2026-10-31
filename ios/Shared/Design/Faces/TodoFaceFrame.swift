import SwiftUI

extension View {
    func taskFaceFrame(_ size: CardSize) -> some View {
        padding(16)
            .fitsDesign(size.points)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
