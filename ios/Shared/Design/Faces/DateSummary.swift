import SwiftUI

struct DateSummary: View {
    let date: Date
    let palette: FacePalette
    let showsGregorian: Bool
    let dayFont: CGFloat
    let dayHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Persian.weekdayName(date))
                .dasto(15)
                .foregroundStyle(palette.accent)
                .faceAccent()
                .lineLimit(1)
                .frame(height: 20)
            Spacer(minLength: 0)
            Text(Persian.number(Persian.dayNumber(date)))
                .dasto(dayFont)
                .foregroundStyle(palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: dayHeight)
            Text(DateText.monthYear(date))
                .dasto(14)
                .foregroundStyle(palette.soft)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(height: 18)
            if showsGregorian {
                Text(DateText.gregorian(date))
                    .dasto(11)
                    .foregroundStyle(palette.soft.opacity(0.8))
                    .lineLimit(1)
                    .frame(height: 14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
