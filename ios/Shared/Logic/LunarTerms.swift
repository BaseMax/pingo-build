import Foundation

struct LunarTerm {
    let amplitude: Double
    let sunPower: Int
    let sun: Int
    let moon: Int
    let latitude: Int
    let node: Int

    init(_ amplitude: Double, e: Int = 0, m: Int = 0, mp: Int = 0, f: Int = 0, node: Int = 0) {
        self.amplitude = amplitude
        self.sunPower = e
        self.sun = m
        self.moon = mp
        self.latitude = f
        self.node = node
    }
}

enum LunarTerms {
    static let newMoon: [LunarTerm] = [
        LunarTerm(-0.40720, mp: 1),
        LunarTerm(0.17241, e: 1, m: 1),
        LunarTerm(0.01608, mp: 2),
        LunarTerm(0.01039, f: 2),
        LunarTerm(0.00739, e: 1, m: -1, mp: 1),
        LunarTerm(-0.00514, e: 1, m: 1, mp: 1),
        LunarTerm(0.00208, e: 2, m: 2),
        LunarTerm(-0.00111, mp: 1, f: -2),
        LunarTerm(-0.00057, mp: 1, f: 2),
        LunarTerm(0.00056, e: 1, m: 1, mp: 2),
        LunarTerm(-0.00042, mp: 3),
        LunarTerm(0.00042, e: 1, m: 1, f: 2),
        LunarTerm(0.00038, e: 1, m: 1, f: -2),
        LunarTerm(-0.00024, e: 1, m: -1, mp: 2),
        LunarTerm(-0.00017, node: 1),
        LunarTerm(-0.00007, m: 2, mp: 1),
        LunarTerm(0.00004, mp: 2, f: -2),
        LunarTerm(0.00004, m: 3),
        LunarTerm(0.00003, m: 1, mp: 1, f: -2),
        LunarTerm(0.00003, mp: 2, f: 2),
        LunarTerm(-0.00003, m: 1, mp: 1, f: 2),
        LunarTerm(0.00003, m: -1, mp: 1, f: 2),
        LunarTerm(-0.00002, m: -1, mp: 1, f: -2),
        LunarTerm(-0.00002, m: 1, mp: 3),
        LunarTerm(0.00002, mp: 4)
    ]

    static let fullMoon: [LunarTerm] = [
        LunarTerm(-0.40614, mp: 1),
        LunarTerm(0.17302, e: 1, m: 1),
        LunarTerm(0.01614, mp: 2),
        LunarTerm(0.01043, f: 2),
        LunarTerm(0.00734, e: 1, m: -1, mp: 1),
        LunarTerm(-0.00515, e: 1, m: 1, mp: 1),
        LunarTerm(0.00209, e: 2, m: 2),
        LunarTerm(-0.00111, mp: 1, f: -2),
        LunarTerm(-0.00057, mp: 1, f: 2),
        LunarTerm(0.00056, e: 1, m: 1, mp: 2),
        LunarTerm(-0.00042, mp: 3),
        LunarTerm(0.00042, e: 1, m: 1, f: 2),
        LunarTerm(0.00038, e: 1, m: 1, f: -2),
        LunarTerm(-0.00024, e: 1, m: -1, mp: 2),
        LunarTerm(-0.00017, node: 1),
        LunarTerm(-0.00007, m: 2, mp: 1),
        LunarTerm(0.00004, mp: 2, f: -2),
        LunarTerm(0.00004, m: 3),
        LunarTerm(0.00003, m: 1, mp: 1, f: -2),
        LunarTerm(0.00003, mp: 2, f: 2),
        LunarTerm(-0.00003, m: 1, mp: 1, f: 2),
        LunarTerm(0.00003, m: -1, mp: 1, f: 2),
        LunarTerm(-0.00002, m: -1, mp: 1, f: -2),
        LunarTerm(-0.00002, m: 1, mp: 3),
        LunarTerm(0.00002, mp: 4)
    ]

    static let quarter: [LunarTerm] = [
        LunarTerm(-0.62801, mp: 1),
        LunarTerm(0.17172, e: 1, m: 1),
        LunarTerm(-0.01183, e: 1, m: 1, mp: 1),
        LunarTerm(0.00862, mp: 2),
        LunarTerm(0.00804, f: 2),
        LunarTerm(0.00454, e: 1, m: -1, mp: 1),
        LunarTerm(0.00204, e: 2, m: 2),
        LunarTerm(-0.00180, mp: 1, f: -2),
        LunarTerm(-0.00070, mp: 1, f: 2),
        LunarTerm(-0.00040, mp: 3),
        LunarTerm(-0.00034, e: 1, m: -1, mp: 2),
        LunarTerm(0.00032, e: 1, m: 1, f: 2),
        LunarTerm(0.00032, e: 1, m: 1, f: -2),
        LunarTerm(-0.00028, e: 2, m: 2, mp: 1),
        LunarTerm(0.00027, e: 1, m: 1, mp: 2),
        LunarTerm(-0.00017, node: 1),
        LunarTerm(-0.00005, m: -1, mp: 1, f: -2),
        LunarTerm(0.00004, mp: 2, f: 2),
        LunarTerm(-0.00004, m: 1, mp: 1, f: 2),
        LunarTerm(0.00004, m: -2, mp: 1),
        LunarTerm(0.00003, m: 1, mp: 1, f: -2),
        LunarTerm(0.00003, m: 3),
        LunarTerm(0.00002, mp: 2, f: -2),
        LunarTerm(0.00002, m: -1, mp: 1, f: 2),
        LunarTerm(-0.00002, m: 1, mp: 3)
    ]

    static let planetary: [(base: Double, rate: Double, quadratic: Double, amplitude: Double)] = [
        (299.77, 0.107408, -0.009173, 0.000325),
        (251.88, 0.016321, 0, 0.000165),
        (251.83, 26.651886, 0, 0.000164),
        (349.42, 36.412478, 0, 0.000126),
        (84.66, 18.206239, 0, 0.000110),
        (141.74, 53.303771, 0, 0.000062),
        (207.14, 2.453732, 0, 0.000060),
        (154.84, 7.306860, 0, 0.000056),
        (34.52, 27.261239, 0, 0.000047),
        (207.19, 0.121824, 0, 0.000042),
        (291.34, 1.844379, 0, 0.000040),
        (161.72, 24.198154, 0, 0.000037),
        (239.56, 25.513099, 0, 0.000035),
        (331.55, 3.592518, 0, 0.000023)
    ]
}
