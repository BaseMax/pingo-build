import Foundation

enum ExpiryCopy {
    static let reinstall = "دوباره با Sideloadly یا Impactor نصبش کن (یا بذار تمدید خودکار انجامش بده). اطلاعاتت می‌مونه."

    static let unknown = "زمان اعتبار نصب پینگو مشخص نیست. اگه با Sideloadly یا Impactor نصبش کردی، هفته‌ای یک بار " + reinstall

    static let expired = "اعتبار نصب تموم شده. پینگو رو " + reinstall

    static let reminderBody = "اعتبار پینگو داره تموم می‌شه. " + reinstall

    static let renewalRule = "اعتبار نصب هفت روزه‌ست؛ هفته‌ای یک بار پینگو رو " + reinstall

    static let reminderHint = "دو اعلان برات می‌فرستم، "
        + Persian.number(24) + " ساعت و " + Persian.number(3) + " ساعت قبل از تموم شدن اعتبار نصب."

    static func soon(span: String) -> String {
        "فقط \(span) دیگه مونده. زودتر پینگو رو " + reinstall
    }
}
