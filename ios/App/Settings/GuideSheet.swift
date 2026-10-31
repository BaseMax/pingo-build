import SwiftUI

struct GuideSheet: View {
    private let kind: PingoKind?
    @Environment(\.dismiss) private var dismiss

    init(kind: PingoKind? = nil) {
        self.kind = kind
    }

    private var highlightsLock: Bool {
        guard let kind else { return false }
        return !kind.accessories.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            LiquidSheetHeader("افزودن به صفحه اصلی") { dismiss() }
            ScrollView {
                VStack(spacing: 28) {
                    tip
                    GuideStepList(
                        title: "صفحه اصلی",
                        symbol: "apps.iphone",
                        steps: GuideStep.home,
                        tint: Color.signal,
                        highlighted: false,
                        baseDelay: 0.1
                    )
                    GuideStepList(
                        title: "صفحه قفل",
                        symbol: "lock.iphone",
                        steps: GuideStep.lock,
                        tint: Color.ocean,
                        highlighted: highlightsLock,
                        baseDelay: 0.55,
                        note: "این ویجت رو می‌تونی روی صفحه قفل هم بذاری."
                    )
                    GuideRenewalCard().reveal(0.9)
                }
                .padding(.horizontal, Layout.gutter)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .background { MeshBackdrop().ignoresSafeArea() }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var tip: some View {
        if let kind {
            GuideKindTip(kind: kind).reveal(0)
        }
    }
}
