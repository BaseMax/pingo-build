import AppIntents

enum ThemeChoice: String, AppEnum, CaseIterable {
    case automatic, paper, haze, sand, signal, sky, leaf, ink

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "رنگ")

    static let caseDisplayRepresentations: [ThemeChoice: DisplayRepresentation] = Dictionary(
        uniqueKeysWithValues: allCases.map { ($0, DisplayRepresentation(title: "\($0.title)")) }
    )

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
