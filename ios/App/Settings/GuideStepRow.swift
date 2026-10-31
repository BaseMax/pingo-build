import SwiftUI

struct GuideStepRow: View {
    let number: Int
    let step: GuideStep
    let tint: Color
    let highlighted: Bool
    let delay: Double

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: step.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.white)
                .symbolEffect(.bounce, value: appeared)
                .frame(width: 46, height: 46)
                .background(tint, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text("قدم " + Persian.number(number))
                    .dasto(12)
                    .foregroundStyle(Color.secondary)
                Text(step.text)
                    .dasto(16)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .panel()
        .overlay {
            RoundedRectangle(cornerRadius: Layout.corner, style: .continuous)
                .strokeBorder(tint.opacity(highlighted ? 0.55 : 0), lineWidth: 1.5)
        }
        .animation(.liquid, value: highlighted)
        .reveal(delay)
        .task {
            try? await Task.sleep(for: .seconds(delay + 0.4))
            guard !Task.isCancelled else { return }
            appeared = true
        }
    }
}
