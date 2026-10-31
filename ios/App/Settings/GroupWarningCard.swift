import SwiftUI

struct GroupWarningCard: View {
    var body: some View {
        if !AppGroup.isShared {
            card
        }
    }

    private var card: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.signal)
            VStack(alignment: .leading, spacing: 6) {
                Text(GroupCopy.cardTitle)
                    .dasto(16)
                Text(GroupCopy.cardMessage)
                    .dasto(14)
                    .foregroundStyle(Color.secondary)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .panel()
        .overlay {
            RoundedRectangle(cornerRadius: Layout.corner, style: .continuous)
                .strokeBorder(Color.signal.opacity(0.4), lineWidth: 1)
        }
    }
}
