import Foundation

enum Fal {
    private static let epoch = Date(timeIntervalSince1970: 1_700_000_000)
    private static let seedStride = 17

    static func verse(on date: Date, seed: Int) -> FalVerse {
        verses[index(on: date, seed: seed)]
    }

    private static func index(on date: Date, seed: Int) -> Int {
        let count = verses.count
        let stride = count.isMultiple(of: seedStride) ? seedStride + 2 : seedStride
        let day = Persian.daysBetween(epoch, date) % count
        let shift = (seed % count) * stride % count
        return ((day + shift) % count + count) % count
    }
}
