import Foundation

enum CardSize: CaseIterable, Hashable {
    case small, medium, large

    var points: CGSize {
        switch self {
        case .small: CGSize(width: 158, height: 158)
        case .medium: CGSize(width: 338, height: 158)
        case .large: CGSize(width: 338, height: 354)
        }
    }

    var title: String {
        switch self {
        case .small: "کوچک"
        case .medium: "متوسط"
        case .large: "بزرگ"
        }
    }
}

enum AccessoryShape: CaseIterable, Hashable {
    case circular, rectangular, inline

    var title: String {
        switch self {
        case .circular: "دایره‌ای"
        case .rectangular: "مستطیلی"
        case .inline: "خطی"
        }
    }
}

enum Theme: String, CaseIterable, Codable, Identifiable {
    case paper, haze, sand, signal, sky, leaf, ink

    var id: String { rawValue }

    var title: String {
        switch self {
        case .paper: "کاغذی"
        case .haze: "مه"
        case .sand: "شن"
        case .signal: "نارنجی"
        case .sky: "آسمان"
        case .leaf: "برگ"
        case .ink: "جوهر"
        }
    }

    var isLight: Bool {
        switch self {
        case .paper, .haze, .sand: true
        default: false
        }
    }
}

enum PingoCategory: String, CaseIterable, Identifiable {
    case time, tasks, inspire

    var id: String { rawValue }

    var title: String {
        switch self {
        case .time: "زمان"
        case .tasks: "کار و عادت"
        case .inspire: "عکس و الهام"
        }
    }

    var symbol: String {
        switch self {
        case .time: "clock.fill"
        case .tasks: "checklist"
        case .inspire: "sparkles"
        }
    }
}

enum LibraryKind: String, CaseIterable, Identifiable, Hashable {
    case note, countdown, habit, todo, counter, album

    var id: String { rawValue }

    var title: String {
        switch self {
        case .note: "یادداشت"
        case .countdown: "شمارش معکوس"
        case .habit: "عادت"
        case .todo: "فهرست کار"
        case .counter: "شمارنده"
        case .album: "آلبوم"
        }
    }

    var plural: String {
        switch self {
        case .note: "یادداشت‌ها"
        case .countdown: "شمارش‌های معکوس"
        case .habit: "عادت‌ها"
        case .todo: "فهرست‌های کار"
        case .counter: "شمارنده‌ها"
        case .album: "آلبوم‌ها"
        }
    }

    var symbol: String {
        switch self {
        case .note: "note.text"
        case .countdown: "hourglass"
        case .habit: "flame.fill"
        case .todo: "checklist"
        case .counter: "plus.circle.fill"
        case .album: "photo.on.rectangle.angled"
        }
    }

    var widget: PingoKind {
        switch self {
        case .note: .note
        case .countdown: .countdown
        case .habit: .habit
        case .todo: .todo
        case .counter: .counter
        case .album: .photo
        }
    }
}

enum PingoKind: String, CaseIterable, Identifiable, Hashable {
    case date, clock, progress, countdown, moon, note, todo, habit, counter, photo, fal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .date: "تقویم شمسی"
        case .clock: "ساعت"
        case .progress: "پیشرفت زمان"
        case .countdown: "شمارش معکوس"
        case .moon: "ماه"
        case .note: "یادداشت"
        case .todo: "فهرست کارها"
        case .habit: "زنجیره عادت"
        case .counter: "شمارنده"
        case .photo: "قاب عکس"
        case .fal: "فال حافظ"
        }
    }

    var about: String {
        switch self {
        case .date: "روز و ماه شمسی با تقویم کامل ماه"
        case .clock: "ساعت آنالوگ و دیجیتال با تاریخ شمسی"
        case .progress: "چند درصد از روز، هفته، ماه و سال گذشته"
        case .countdown: "تا روز مهمت چند روز مونده"
        case .moon: "فاز واقعی ماه برای امشب"
        case .note: "یه جمله که نباید فراموشش کنی"
        case .todo: "کارهای امروز رو از روی صفحه اصلی تیک بزن"
        case .habit: "هر روز با یه لمس ثبتش کن"
        case .counter: "آب، ذکر یا هر چیزی که می‌شماری"
        case .photo: "عکس‌های مورد علاقه‌ت، با اسلایدشو"
        case .fal: "هر روز یه بیت، با یه لمس فال جدید"
        }
    }

    var symbol: String {
        switch self {
        case .date: "calendar"
        case .clock: "clock.fill"
        case .progress: "circle.dashed"
        case .countdown: "hourglass"
        case .moon: "moon.stars.fill"
        case .note: "pin.fill"
        case .todo: "checklist"
        case .habit: "flame.fill"
        case .counter: "plus.circle.fill"
        case .photo: "photo.fill"
        case .fal: "sparkles"
        }
    }

    var category: PingoCategory {
        switch self {
        case .date, .clock, .progress, .countdown, .moon: .time
        case .note, .todo, .habit, .counter: .tasks
        case .photo, .fal: .inspire
        }
    }

    var defaultTheme: Theme {
        switch self {
        case .date: .paper
        case .clock: .ink
        case .progress: .ink
        case .countdown: .signal
        case .moon: .ink
        case .note: .sand
        case .todo: .paper
        case .habit: .leaf
        case .counter: .sky
        case .photo: .ink
        case .fal: .sand
        }
    }

    var sizes: [CardSize] {
        switch self {
        case .date, .note, .todo, .photo: [.small, .medium, .large]
        case .fal: [.medium, .large]
        default: [.small, .medium]
        }
    }

    var accessories: [AccessoryShape] {
        switch self {
        case .date: [.circular, .rectangular, .inline]
        case .clock: [.circular]
        case .progress: [.circular, .rectangular]
        case .countdown: [.circular, .rectangular, .inline]
        case .moon: [.circular]
        case .habit: [.circular]
        case .counter: [.circular]
        default: []
        }
    }

    var isInteractive: Bool {
        switch self {
        case .todo, .habit, .counter, .fal: true
        default: false
        }
    }

    var library: LibraryKind? {
        switch self {
        case .note: .note
        case .countdown: .countdown
        case .habit: .habit
        case .todo: .todo
        case .counter: .counter
        case .photo: .album
        default: nil
        }
    }

    var usesPhotos: Bool { self == .photo }

    func refresh(albumMinutes: Int? = nil) -> Refresh {
        switch self {
        case .progress: .every(minutes: 30)
        case .moon: .every(minutes: 120)
        case .clock: .minutely(count: 60)
        case .photo: .slideshow(minutes: max(albumMinutes ?? 60, 1), count: 24)
        default: .midnight
        }
    }
}

struct WidgetSelection: Hashable {
    var itemID: String? = nil
    var theme: Theme? = nil
}

struct TimelinePlan: Equatable {
    let dates: [Date]
    let reload: Date
}

enum Refresh: Equatable {
    case midnight
    case every(minutes: Int)
    case minutely(count: Int)
    case slideshow(minutes: Int, count: Int)

    func plan(from now: Date) -> TimelinePlan {
        switch self {
        case .midnight:
            let boundary = Persian.calendar.startOfDay(for: Persian.shift(now, days: 1))
            return TimelinePlan(dates: [now, boundary], reload: boundary.addingTimeInterval(60))
        case .every(let minutes):
            return TimelinePlan(dates: [now], reload: now.addingTimeInterval(Double(max(minutes, 1)) * 60))
        case .minutely(let count):
            return Self.steps(from: now, minutes: 1, count: count)
        case .slideshow(let minutes, let count):
            return Self.steps(from: now, minutes: minutes, count: count)
        }
    }

    private static func steps(from now: Date, minutes: Int, count: Int) -> TimelinePlan {
        let step = Double(max(minutes, 1)) * 60
        let total = max(count, 1)
        let start = Date(timeIntervalSince1970: (now.timeIntervalSince1970 / step).rounded(.down) * step)
        let dates = (0..<total).map { start.addingTimeInterval(Double($0) * step) }
        return TimelinePlan(dates: dates, reload: start.addingTimeInterval(Double(total) * step))
    }
}
