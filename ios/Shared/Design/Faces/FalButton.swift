import AppIntents
import SwiftUI

struct FalButton: View {
    let large: Bool
    let palette: FacePalette

    var body: some View {
        Button(intent: NewFalIntent()) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                Text("فال جدید")
                    .dasto(large ? 15 : 14)
            }
            .foregroundStyle(palette.onAccent)
            .padding(.horizontal, large ? 22 : 16)
            .frame(height: large ? 38 : 32)
            .background { Capsule().fill(palette.accent).faceAccent() }
        }
        .buttonStyle(.plain)
    }
}
