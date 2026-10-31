import Foundation

struct GuideStep: Identifiable {
    let symbol: String
    let text: String

    var id: String { symbol }
}

extension GuideStep {
    static let home: [GuideStep] = [
        GuideStep(symbol: "hand.tap.fill", text: "روی یه جای خالی از صفحه اصلی انگشتت رو نگه دار تا آیکون‌ها بلرزن."),
        GuideStep(symbol: "plus", text: "دکمه + بالای صفحه رو بزن."),
        GuideStep(symbol: "magnifyingglass", text: "پینگو رو توی فهرست ویجت‌ها پیدا کن."),
        GuideStep(symbol: "square.grid.2x2.fill", text: "ویجت و سایز دلخواهت رو انتخاب کن."),
        GuideStep(symbol: "checkmark.circle.fill", text: "افزودن ویجت رو بزن. تمام!")
    ]

    static let lock: [GuideStep] = [
        GuideStep(symbol: "lock.fill", text: "روی صفحه قفل انگشتت رو نگه دار و «سفارشی‌سازی» رو بزن."),
        GuideStep(symbol: "plus.rectangle.fill", text: "جای ویجت‌ها، یعنی زیر ساعت، رو بزن تا ویجت اضافه کنی."),
        GuideStep(symbol: "sparkles", text: "پینگو رو پیدا کن و ویجت دلخواهت رو بزن.")
    ]
}
