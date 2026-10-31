import SwiftUI

struct ResetSection: View {
    @State private var isConfirming = false
    @State private var didWipe = false
    @State private var isWiping = false

    var body: some View {
        SettingsGroup("پاک‌سازی", symbol: "trash.fill") {
            VStack(spacing: 12) {
                Button(role: .destructive) {
                    Haptics.tap()
                    isConfirming = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 15, weight: .semibold))
                        Text("پاک کردن همه داده‌ها")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(LiquidButtonStyle(prominent: true, tint: Color.red))
                .disabled(isWiping)
                if didWipe {
                    Text("همه‌چیز پاک شد. هر وقت خواستی از اول شروع کن.")
                        .dasto(14)
                        .foregroundStyle(Color.secondary)
                        .transition(.blurFade)
                }
            }
            .panel()
            .animation(.liquid, value: didWipe)
        }
        .confirmationDialog("همه داده‌ها پاک بشن؟", isPresented: $isConfirming, titleVisibility: .visible) {
            Button("پاک کن", role: .destructive, action: wipe)
            Button("نه، بمونه", role: .cancel) {}
        } message: {
            Text("همه یادداشت‌ها، عادت‌ها، فهرست‌ها، شمارنده‌ها و عکس‌های آلبوم‌ها پاک می‌شن و برنمی‌گردن. بهتره اول یه نسخه پشتیبان بگیری.")
        }
    }

    private func wipe() {
        isWiping = true
        Task {
            await DataWiper.wipeAll()
            isWiping = false
            Haptics.warning()
            withAnimation(.liquid) { didWipe = true }
        }
    }
}
