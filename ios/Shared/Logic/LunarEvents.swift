import Foundation

struct LunarArguments {
    let k: Double
    let t: Double

    var e: Double { 1 - 0.002516 * t - 0.0000074 * t * t }
    var sun: Double { 2.5534 + 29.10535670 * k - 0.0000014 * t * t - 0.00000011 * t * t * t }
    var moon: Double { 201.5643 + 385.81693528 * k + 0.0107582 * t * t + 0.00001238 * t * t * t - 0.000000058 * t * t * t * t }
    var latitude: Double { 160.7108 + 390.67050284 * k - 0.0016118 * t * t - 0.00000227 * t * t * t + 0.000000011 * t * t * t * t }
    var node: Double { 124.7746 - 1.56375588 * k + 0.0020672 * t * t + 0.00000215 * t * t * t }

    init(k: Double) {
        self.k = k
        self.t = k / 1236.85
    }

    func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }

    func value(of term: LunarTerm) -> Double {
        let angle = Double(term.sun) * sun + Double(term.moon) * moon + Double(term.latitude) * latitude + Double(term.node) * node
        return term.amplitude * pow(e, Double(term.sunPower)) * sin(radians(angle))
    }

    var planetaryCorrection: Double {
        LunarTerms.planetary.reduce(0) { total, entry in
            total + entry.amplitude * sin(radians(entry.base + entry.rate * k + entry.quadratic * t * t))
        }
    }

    var quarterShift: Double {
        0.00306 - 0.00038 * e * cos(radians(sun)) + 0.00026 * cos(radians(moon))
            - 0.00002 * cos(radians(moon - sun)) + 0.00002 * cos(radians(moon + sun)) + 0.00002 * cos(radians(2 * latitude))
    }
}

enum LunarEvents {
    static let epochJDE = 2451550.09766
    static let meanMonth = 29.530588861
    static let unixEpochJD = 2440587.5

    static func date(k: Double) -> Date {
        let jde = ephemerisDay(k: k)
        let year = 2000 + (jde - 2451545) / 365.25
        let universal = jde - deltaT(year: year) / 86400
        return Date(timeIntervalSince1970: (universal - unixEpochJD) * 86400)
    }

    static func ephemerisDay(k: Double) -> Double {
        let args = LunarArguments(k: k)
        let t = args.t
        let mean = epochJDE + meanMonth * k + 0.00015437 * t * t - 0.000000150 * t * t * t + 0.00000000073 * t * t * t * t
        return mean + corrections(args, quarterIndex: quarterIndex(k))
    }

    static func deltaT(year: Double) -> Double {
        if year < 2050 {
            let t = max(year, 1990) - 2000
            return 62.92 + 0.32217 * t + 0.005589 * t * t
        }
        let u = (year - 1820) / 100
        return -20 + 32 * u * u - 0.5628 * (2150 - min(year, 2150))
    }

    static func approximateIndex(for date: Date) -> Double {
        let jd = date.timeIntervalSince1970 / 86400 + unixEpochJD
        return ((jd - epochJDE) / meanMonth).rounded(.down)
    }

    private static func quarterIndex(_ k: Double) -> Int {
        Int(((k - k.rounded(.down)) * 4).rounded()) % 4
    }

    private static func corrections(_ args: LunarArguments, quarterIndex: Int) -> Double {
        let terms: [LunarTerm]
        switch quarterIndex {
        case 0: terms = LunarTerms.newMoon
        case 2: terms = LunarTerms.fullMoon
        default: terms = LunarTerms.quarter
        }
        let periodic = terms.reduce(0) { $0 + args.value(of: $1) }
        let shift = quarterIndex == 1 ? args.quarterShift : quarterIndex == 3 ? -args.quarterShift : 0
        return periodic + shift + args.planetaryCorrection
    }
}
