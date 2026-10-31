import SwiftUI

struct GuideStepList: View {
    let title: String
    let symbol: String
    let steps: [GuideStep]
    let tint: Color
    let highlighted: Bool
    let baseDelay: Double
    var note: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title, symbol: symbol)
            if let note, highlighted {
                Text(note)
                    .dasto(13)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 4)
                    .transition(.blurFade)
            }
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                GuideStepRow(
                    number: index + 1,
                    step: step,
                    tint: tint,
                    highlighted: highlighted,
                    delay: baseDelay + 0.07 * Double(index)
                )
            }
        }
        .animation(.liquid, value: highlighted)
    }
}
