import SwiftUI

struct TodoCheckbox: View {
    let done: Bool
    let size: CGFloat
    let palette: FacePalette

    var body: some View {
        ZStack {
            if done {
                Circle().fill(palette.accent).faceAccent()
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(palette.onAccent)
            } else {
                Circle().strokeBorder(palette.soft, lineWidth: 1.6)
            }
        }
        .frame(width: size, height: size)
    }
}
