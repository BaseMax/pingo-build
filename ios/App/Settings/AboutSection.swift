import SwiftUI

struct AboutSection: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        SettingsGroup("درباره پینگو", symbol: "info.circle.fill") {
            identity
            SettingsLinkRow(
                title: "راهنمای افزودن ویجت",
                subtitle: "صفحه اصلی و صفحه قفل، قدم به قدم",
                symbol: "questionmark.circle.fill"
            ) {
                router.open(.guide(nil))
            }
            SettingsLinkRow(
                title: "دوباره دیدن معرفی",
                subtitle: "دفعه بعد که پینگو باز شد، از اول شروع می‌شه",
                symbol: "play.circle.fill"
            ) {
                LiveSettings.shared.value.onboarded = false
            }
            Text("ساخته شده برای استفاده شخصی")
                .dasto(13)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
        }
    }

    private var identity: some View {
        LiquidRow(title: "پینگو", subtitle: AppVersion.display) {
            RowSymbolTile(symbol: "sparkles")
        } trailing: {
            EmptyView()
        }
    }
}
