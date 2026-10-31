import AppIntents
import SwiftUI

struct CounterStepButton: View {
    let counterID: String
    let delta: Int
    let diameter: CGFloat
    let dimmed: Bool
    let palette: FacePalette

    private var adds: Bool { delta > 0 }

    var body: some View {
        Button(intent: CounterStepIntent(counterID: counterID, delta: delta)) {
            Image(systemName: adds ? "plus" : "minus")
                .font(.system(size: diameter * 0.42, weight: .bold))
                .foregroundStyle(adds ? palette.onAccent : palette.ink)
                .frame(width: diameter, height: diameter)
                .background { disc }
                .opacity(dimmed ? 0.35 : 1)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var disc: some View {
        if adds {
            Circle().fill(palette.accent).faceAccent()
        } else {
            Circle().fill(palette.ink.opacity(0.12))
        }
    }
}
