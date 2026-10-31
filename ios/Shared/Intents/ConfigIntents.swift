import AppIntents
import WidgetKit

protocol SelectionProviding {
    var selection: WidgetSelection { get }
}

struct ThemeConfigIntent: WidgetConfigurationIntent, SelectionProviding {
    static let title: LocalizedStringResource = "تنظیم ویجت"
    static let description = IntentDescription("رنگ ویجت رو انتخاب کن.")

    @Parameter(title: "رنگ", default: .automatic) var theme: ThemeChoice

    init() {}

    var selection: WidgetSelection {
        theme.selection(itemID: nil)
    }
}

struct NoteConfigIntent: WidgetConfigurationIntent, SelectionProviding {
    static let title: LocalizedStringResource = "یادداشت"
    static let description = IntentDescription("یادداشتی که روی ویجت دیده می‌شه رو انتخاب کن.")

    @Parameter(title: "یادداشت") var note: NoteEntity?
    @Parameter(title: "رنگ", default: .automatic) var theme: ThemeChoice

    init() {}

    var selection: WidgetSelection {
        theme.selection(itemID: note?.id)
    }
}

struct CountdownConfigIntent: WidgetConfigurationIntent, SelectionProviding {
    static let title: LocalizedStringResource = "شمارش معکوس"
    static let description = IntentDescription("رویدادی که می‌خوای تا اون روز بشماری رو انتخاب کن.")

    @Parameter(title: "رویداد") var countdown: CountdownEntity?
    @Parameter(title: "رنگ", default: .automatic) var theme: ThemeChoice

    init() {}

    var selection: WidgetSelection {
        theme.selection(itemID: countdown?.id)
    }
}

struct HabitConfigIntent: WidgetConfigurationIntent, SelectionProviding {
    static let title: LocalizedStringResource = "زنجیره عادت"
    static let description = IntentDescription("عادتی که می‌خوای هر روز ثبتش کنی رو انتخاب کن.")

    @Parameter(title: "عادت") var habit: HabitEntity?
    @Parameter(title: "رنگ", default: .automatic) var theme: ThemeChoice

    init() {}

    var selection: WidgetSelection {
        theme.selection(itemID: habit?.id)
    }
}

struct TodoConfigIntent: WidgetConfigurationIntent, SelectionProviding {
    static let title: LocalizedStringResource = "فهرست کارها"
    static let description = IntentDescription("فهرستی که می‌خوای از روی صفحه اصلی تیک بزنی رو انتخاب کن.")

    @Parameter(title: "فهرست") var list: TodoEntity?
    @Parameter(title: "رنگ", default: .automatic) var theme: ThemeChoice

    init() {}

    var selection: WidgetSelection {
        theme.selection(itemID: list?.id)
    }
}

struct CounterConfigIntent: WidgetConfigurationIntent, SelectionProviding {
    static let title: LocalizedStringResource = "شمارنده"
    static let description = IntentDescription("چیزی که می‌خوای بشماری رو انتخاب کن.")

    @Parameter(title: "شمارنده") var counter: CounterEntity?
    @Parameter(title: "رنگ", default: .automatic) var theme: ThemeChoice

    init() {}

    var selection: WidgetSelection {
        theme.selection(itemID: counter?.id)
    }
}

struct AlbumConfigIntent: WidgetConfigurationIntent, SelectionProviding {
    static let title: LocalizedStringResource = "قاب عکس"
    static let description = IntentDescription("آلبومی که توی قاب عکس نشون داده می‌شه رو انتخاب کن.")

    @Parameter(title: "آلبوم") var album: AlbumEntity?

    init() {}

    var selection: WidgetSelection {
        WidgetSelection(itemID: album?.id)
    }
}
