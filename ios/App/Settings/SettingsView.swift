import SwiftUI

struct SettingsView: View {
    @State private var expiry = ProvisioningProfile.embedded(in: .main)?.expirationDate
    @State private var now = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    GroupWarningCard()
                    InstallValidityCard(expiry: expiry, now: now).reveal(0)
                    ReminderSection().reveal(0.06)
                    AppearanceSection().reveal(0.12)
                    BackupSection().reveal(0.18)
                    ResetSection().reveal(0.24)
                    AboutSection().reveal(0.3)
                }
                .padding(.horizontal, Layout.gutter)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .navigationTitle("تنظیمات")
            .navigationBarTitleDisplayMode(.large)
            .liquidScreen()
            .reloadsOnActive { now = Date() }
        }
    }
}
