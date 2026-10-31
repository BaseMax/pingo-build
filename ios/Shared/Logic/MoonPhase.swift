import Foundation

struct MoonPhase {
    static let synodic = LunarEvents.meanMonth
    static let names = ["ماه نو", "هلال فزاینده", "تربیع اول", "بدر فزاینده", "ماه کامل", "بدر کاهنده", "تربیع آخر", "هلال کاهنده"]
    static let maxAge = 29

    let fraction: Double
    let ageDays: Double

    init(date: Date) {
        let cycle = LunarCycle(date: date)
        fraction = cycle.fraction
        ageDays = cycle.ageDays
    }

    var illumination: Double { (1 - cos(2 * .pi * fraction)) / 2 }
    var name: String { Self.names[Int((fraction * 8).rounded()) % 8] }
    var age: Int { min(Int(ageDays.rounded()), Self.maxAge) }
}

struct LunarCycle {
    let fraction: Double
    let ageDays: Double

    init(date: Date) {
        var k = LunarEvents.approximateIndex(for: date)
        while LunarEvents.date(k: k) > date { k -= 1 }
        while LunarEvents.date(k: k + 1) <= date { k += 1 }
        let events = (0...4).map { LunarEvents.date(k: k + Double($0) * 0.25) }
        let index = events.dropFirst().firstIndex { $0 > date }.map { $0 - 1 } ?? 3
        let span = events[index + 1].timeIntervalSince(events[index])
        let within = date.timeIntervalSince(events[index]) / span
        fraction = min((Double(index) + within) / 4, 1 - Double.ulpOfOne)
        ageDays = date.timeIntervalSince(events[0]) / 86400
    }
}
