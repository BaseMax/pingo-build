import SwiftUI

struct OnboardingClusterPage: View {
    private static let canvas = CGSize(width: 360, height: 440)

    var body: some View {
        VStack(spacing: 20) {
            cluster
            VStack(spacing: 8) {
                Text("یازده ویجت، هر کدوم با رنگ خودت")
                    .dasto(26)
                    .multilineTextAlignment(.center)
                Text("تقویم، ساعت، عادت، فال و کلی چیز دیگه")
                    .dasto(15)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
            .reveal(0.5)
            .pageParallax(0.5)
        }
        .padding(.top, 8)
    }

    private var cluster: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(OnboardingTile.all) { tile in
                    OnboardingTileView(tile: tile)
                }
            }
            .frame(width: Self.canvas.width, height: Self.canvas.height)
            .scaleEffect(fit(in: proxy.size))
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func fit(in available: CGSize) -> CGFloat {
        min(1, available.width / Self.canvas.width, available.height / Self.canvas.height)
    }
}
