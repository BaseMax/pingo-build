import SwiftUI

struct GuideRenewalCard: View {
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.signal)
                .symbolEffect(.bounce, value: appeared)
            Text(ExpiryCopy.renewalRule)
                .dasto(15)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .panel()
        .overlay {
            RoundedRectangle(cornerRadius: Layout.corner, style: .continuous)
                .strokeBorder(Color.signal.opacity(0.35), lineWidth: 1)
        }
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            appeared = true
        }
    }
}
