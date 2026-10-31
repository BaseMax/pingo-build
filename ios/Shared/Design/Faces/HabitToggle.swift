import AppIntents
import SwiftUI

struct HabitToggle: View {
    let habitID: String
    let done: Bool
    let palette: FacePalette

    var body: some View {
        Button(intent: ToggleHabitIntent(habitID: habitID)) {
            HStack(spacing: 6) {
                Image(systemName: done ? "checkmark" : "plus")
                    .font(.system(size: 12, weight: .bold))
                Text(done ? "انجام شد" : "ثبت امروز")
                    .dasto(14)
            }
            .foregroundStyle(done ? palette.onAccent : palette.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background { shape }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var shape: some View {
        if done {
            Capsule().fill(palette.accent).faceAccent()
        } else {
            Capsule().fill(palette.ink.opacity(0.12))
        }
    }
}
