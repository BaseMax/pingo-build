import SwiftUI

struct AppContent: View {
    @Bindable var router: AppRouter

    @Environment(\.scenePhase) private var scenePhase

    private var settings: LiveSettings { LiveSettings.shared }

    private var scheme: ColorScheme? {
        switch settings.value.appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    private var needsOnboarding: Bool { !settings.value.onboarded }

    var body: some View {
        ZStack {
            root
            onboarding
        }
        .animation(.liquid, value: needsOnboarding)
        .environment(router)
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Persian.locale)
        .environment(\.animates, true)
        .tint(Color.signal)
        .preferredColorScheme(scheme)
        .softensMotion()
        .onOpenURL { router.handle($0) }
        .sheet(item: $router.sheet) { guide(for: $0) }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { activate() }
        }
    }

    private var root: some View {
        RootView()
            .environment(\.animates, !needsOnboarding)
            .allowsHitTesting(!needsOnboarding)
            .accessibilityHidden(needsOnboarding)
    }

    @ViewBuilder
    private var onboarding: some View {
        if needsOnboarding {
            OnboardingView(onFinish: finishOnboarding)
                .transition(.blurFade)
                .zIndex(10)
        }
    }

    @ViewBuilder
    private func guide(for sheet: AppSheet) -> some View {
        switch sheet {
        case .guide(let kind):
            GuideSheet(kind: kind)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private func activate() {
        settings.reload()
        let ready = !needsOnboarding
        Task {
            if ready {
                await ReminderScheduler.prepare()
            } else {
                await ReminderScheduler.refresh()
            }
        }
    }

    private func finishOnboarding() {
        settings.value.onboarded = true
        Task { await ReminderScheduler.prepare() }
    }
}
