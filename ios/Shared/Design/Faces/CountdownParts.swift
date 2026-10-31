import SwiftUI

struct CountdownHeader: View {
    let info: CountdownInfo
    let palette: FacePalette

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: info.symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.accent)
                .faceAccent()
            Text(info.title)
                .dasto(15)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
        }
    }
}

struct CountdownHeadline: View {
    let info: CountdownInfo
    let palette: FacePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if info.isToday {
                today
            } else {
                number
                caption
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var number: some View {
        Text(info.number)
            .dasto(64)
            .foregroundStyle(palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .contentTransition(.numericText())
            .frame(maxWidth: .infinity, minHeight: 62, maxHeight: 62, alignment: .leading)
    }

    private var caption: some View {
        Text(info.caption)
            .dasto(15)
            .foregroundStyle(palette.soft)
    }

    private var today: some View {
        VStack(alignment: .leading, spacing: 2) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(palette.accent)
                .faceAccent()
            Text("امروزه!")
                .dasto(40)
                .foregroundStyle(palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

struct CountdownArc: View {
    let progress: Double
    let symbol: String
    let palette: FacePalette

    @Environment(\.animates) private var animates
    @State private var shown = false

    private var value: Double { animates && !shown ? 0 : progress }

    var body: some View {
        ZStack {
            Circle().stroke(palette.track, lineWidth: 6)
            Circle()
                .trim(from: 0, to: value)
                .stroke(palette.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .opacity(value > 0.001 ? 1 : 0)
                .faceAccent()
            Image(systemName: symbol)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(palette.ink.opacity(0.8))
        }
        .frame(width: 92, height: 92)
        .onAppear {
            withAnimation(.smooth(duration: 0.9)) { shown = true }
        }
    }
}

struct CountdownAside: View {
    let info: CountdownInfo
    let palette: FacePalette

    var body: some View {
        VStack(spacing: 8) {
            CountdownArc(progress: info.progress, symbol: info.symbol, palette: palette)
            Text(info.dateText)
                .dasto(14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxHeight: .infinity)
    }
}
