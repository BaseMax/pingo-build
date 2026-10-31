import SwiftUI

struct DateMonthGrid: View {
    let date: Date
    let palette: FacePalette
    let width: CGFloat
    let height: CGFloat
    let cellFont: CGFloat
    let headerFont: CGFloat

    private var cells: [Int?] {
        let raw = Persian.monthCells(for: date)
        let rows = max((raw.count + 6) / 7, 1)
        return raw + Array<Int?>(repeating: nil, count: rows * 7 - raw.count)
    }

    private var rowCount: Int { cells.count / 7 }
    private var headerHeight: CGFloat { headerFont + 7 }
    private var cellWidth: CGFloat { width / 7 }
    private var cellHeight: CGFloat { (height - headerHeight) / CGFloat(rowCount) }
    private var marker: CGFloat { min(cellWidth, cellHeight) - 1 }

    var body: some View {
        VStack(spacing: 0) {
            header
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { column in
                        cell(cells[row * 7 + column], column: column)
                    }
                }
            }
        }
        .frame(width: width, height: height, alignment: .top)
    }

    private var header: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { column in
                Text(Persian.weekdayLetters[column])
                    .dasto(headerFont)
                    .foregroundStyle(column == 6 ? palette.accent : palette.soft.opacity(0.75))
                    .frame(width: cellWidth, height: headerHeight)
            }
        }
    }

    private func cell(_ day: Int?, column: Int) -> some View {
        let isToday = day == Persian.dayNumber(date)
        return Text(day.map(Persian.number) ?? "")
            .dasto(cellFont)
            .foregroundStyle(color(isToday: isToday, column: column))
            .frame(width: marker, height: marker)
            .background {
                if isToday {
                    Circle().fill(palette.accent).faceAccent()
                }
            }
            .frame(width: cellWidth, height: cellHeight)
    }

    private func color(isToday: Bool, column: Int) -> Color {
        if isToday { return palette.onAccent }
        return column == 6 ? palette.accent : palette.ink
    }
}
