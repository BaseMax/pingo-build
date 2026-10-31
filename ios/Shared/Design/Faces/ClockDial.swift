import SwiftUI

struct ClockDial: View {
    let date: Date
    let palette: FacePalette
    let diameter: CGFloat
    var showsFace: Bool = true

    private var hourAngle: Double { ClockMath.hourAngle(date, calendar: Persian.calendar) }
    private var minuteAngle: Double { ClockMath.minuteAngle(date, calendar: Persian.calendar) }

    var body: some View {
        ZStack {
            if showsFace {
                Circle().fill(palette.track)
            }
            ticks
            hand(length: diameter * 0.27, width: diameter * 0.045, angle: hourAngle, opacity: 1)
            hand(length: diameter * 0.39, width: diameter * 0.03, angle: minuteAngle, opacity: 0.85)
            Circle()
                .fill(palette.accent)
                .frame(width: diameter * 0.075, height: diameter * 0.075)
                .faceAccent()
        }
        .frame(width: diameter, height: diameter)
    }

    private var ticks: some View {
        ForEach(0..<12, id: \.self) { index in
            tick(major: index % 3 == 0)
                .rotationEffect(.degrees(Double(index) * 30))
        }
    }

    private func tick(major: Bool) -> some View {
        let length = diameter * (major ? 0.085 : 0.05)
        return Capsule()
            .fill(major ? palette.ink : palette.soft)
            .frame(width: major ? diameter * 0.026 : diameter * 0.016, height: length)
            .offset(y: -(diameter / 2 - length / 2 - diameter * 0.055))
    }

    private func hand(length: CGFloat, width: CGFloat, angle: Double, opacity: Double) -> some View {
        Capsule()
            .fill(palette.ink.opacity(opacity))
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
    }
}
