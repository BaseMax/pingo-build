import Foundation

struct MoonPhase {
    static let synodic = 29.530588853
    static let reference = 947182440.0
    static let names = ["ماه نو", "هلال فزاینده", "تربیع اول", "بدر فزاینده", "ماه کامل", "بدر کاهنده", "تربیع آخر", "هلال کاهنده"]

    let fraction: Double

    init(date: Date) {
        let cycle = (date.timeIntervalSince1970 - Self.reference) / 86400 / Self.synodic
        fraction = cycle - cycle.rounded(.down)
    }

    var illumination: Double { (1 - cos(2 * .pi * fraction)) / 2 }
    var name: String { Self.names[Int((fraction * 8).rounded()) % 8] }
    var age: Int { Int((fraction * Self.synodic).rounded()) }
}
