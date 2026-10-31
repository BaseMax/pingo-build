import SwiftUI

private struct StoreStamp: ViewModifier {
    @Binding var stamp: Date

    @Environment(\.animates) private var isVisible

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .pingoStoreChanged)) { _ in
                refresh()
            }
            .onChange(of: isVisible) { _, visible in
                if visible { refresh() }
            }
    }

    private func refresh() {
        guard isVisible else { return }
        withAnimation(.liquidSoft) { stamp = .now }
    }
}

private struct MinuteTick: ViewModifier {
    let isEnabled: Bool
    @Binding var stamp: Date

    @Environment(\.animates) private var isVisible

    private var isRunning: Bool { isEnabled && isVisible }

    func body(content: Content) -> some View {
        content.task(id: isRunning) {
            guard isRunning else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.secondsToNextMinute()))
                guard !Task.isCancelled else { return }
                withAnimation(.liquidSoft) { stamp = .now }
            }
        }
    }

    private static func secondsToNextMinute() -> Double {
        let seconds = Calendar.current.component(.second, from: .now)
        return Double(60 - seconds) + 0.2
    }
}

extension View {
    func refreshesOnStoreChange(_ stamp: Binding<Date>) -> some View {
        modifier(StoreStamp(stamp: stamp))
    }

    func ticksEveryMinute(_ isEnabled: Bool, stamp: Binding<Date>) -> some View {
        modifier(MinuteTick(isEnabled: isEnabled, stamp: stamp))
    }
}
