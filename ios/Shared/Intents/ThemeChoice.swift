import AppIntents

enum ThemeChoice: String, AppEnum, CaseIterable {
    case automatic, paper, haze, sand, signal, sky, leaf, ink

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "رنگ")

    static let caseDisplayRepresentations: [ThemeChoice: DisplayRepresentation] = [
        .automatic: DisplayRepresentation(title: "خودکار"),
        .paper: DisplayRepresentation(title: "کاغذی"),
        .haze: DisplayRepresentation(title: "مه"),
        .sand: DisplayRepresentation(title: "شن"),
        .signal: DisplayRepresentation(title: "نارنجی"),
        .sky: DisplayRepresentation(title: "آسمان"),
        .leaf: DisplayRepresentation(title: "برگ"),
        .ink: DisplayRepresentation(title: "جوهر")
    ]

    var theme: Theme? {
        Theme(rawValue: rawValue)
    }

    var title: String {
        theme?.title ?? "خودکار"
    }

    func selection(itemID: String?) -> WidgetSelection {
        WidgetSelection(itemID: itemID, theme: theme)
    }
}
