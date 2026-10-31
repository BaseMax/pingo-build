import SwiftUI

struct FloatingScrim: View {
    private let onTap: () -> Void

    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.6)
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement()
        .accessibilityLabel("بستن منو")
        .accessibilityAddTraits(.isButton)
        .transition(.opacity)
    }
}
