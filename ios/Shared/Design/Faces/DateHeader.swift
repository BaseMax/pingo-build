import SwiftUI

struct DateHeader: View {
    let date: Date
    let palette: FacePalette
    let showsGregorian: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Persian.weekdayName(date))
                    .dasto(18)
                    .foregroundStyle(palette.accent)
                    .faceAccent()
                    .lineLimit(1)
                Text(DateText.monthYear(date))
                    .dasto(15)
                    .foregroundStyle(palette.soft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if showsGregorian {
                    Text(DateText.gregorian(date))
                        .dasto(11)
                        .foregroundStyle(palette.soft.opacity(0.8))
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            Text(Persian.number(Persian.dayNumber(date)))
                .dasto(64)
                .foregroundStyle(palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: 60)
        }
    }
}
