import SwiftUI

struct LiquidSheetHeader: View {
    private let title: String
    private let onClose: () -> Void

    init(_ title: String, onClose: @escaping () -> Void) {
        self.title = title
        self.onClose = onClose
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .dasto(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private var closeButton: some View {
        Button {
            Haptics.tap()
            onClose()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.primary)
                .frame(width: 38, height: 38)
                .glassCircle(interactive: true)
        }
        .buttonStyle(Pressable())
        .accessibilityLabel("بستن")
    }
}
