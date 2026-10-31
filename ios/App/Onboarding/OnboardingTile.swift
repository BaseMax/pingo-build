import SwiftUI

struct OnboardingTile: Identifiable {
    let kind: PingoKind
    let size: CardSize
    let offset: CGSize
    let scale: CGFloat
    let tilt: Double
    let delay: Double
    let depth: CGFloat
    let bobPeriod: Double

    var id: PingoKind { kind }

    static let all: [OnboardingTile] = [
        OnboardingTile(kind: .date, size: .medium, offset: CGSize(width: 0, height: -132), scale: 0.95, tilt: -2, delay: 0.1, depth: 1.2, bobPeriod: 2.8),
        OnboardingTile(kind: .progress, size: .small, offset: CGSize(width: -95, height: 24), scale: 0.88, tilt: 3, delay: 0.2, depth: 0.9, bobPeriod: 3.3),
        OnboardingTile(kind: .habit, size: .small, offset: CGSize(width: 95, height: 56), scale: 0.88, tilt: -3, delay: 0.3, depth: 1.5, bobPeriod: 2.5),
        OnboardingTile(kind: .moon, size: .small, offset: CGSize(width: -8, height: 168), scale: 0.78, tilt: 2, delay: 0.4, depth: 1.0, bobPeriod: 3.6)
    ]
}

struct OnboardingTileView: View {
    let tile: OnboardingTile

    var body: some View {
        FacePreview(kind: tile.kind, size: tile.size)
            .allowsHitTesting(false)
            .tiltParallax(0.8)
            .modifier(OnboardingBob(period: tile.bobPeriod, distance: 6))
            .scaleEffect(tile.scale)
            .rotationEffect(.degrees(tile.tilt))
            .offset(tile.offset)
            .reveal(tile.delay)
            .pageParallax(tile.depth)
    }
}
