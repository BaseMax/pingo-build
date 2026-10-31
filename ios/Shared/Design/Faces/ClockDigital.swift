import SwiftUI

struct ClockDigital: View {
    let date: Date
    let palette: FacePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ClockMath.digital(date, calendar: Persian.calendar))
                .dasto(46)
                .foregroundStyle(palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
                .frame(height: 50)
            Text(Persian.weekdayName(date))
                .dasto(15)
                .foregroundStyle(palette.accent)
                .faceAccent()
                .lineLimit(1)
            Text(Persian.shortDate(date))
                .dasto(14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
