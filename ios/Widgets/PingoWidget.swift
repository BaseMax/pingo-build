import SwiftUI
import WidgetKit
import AppIntents

struct PingoEntry: TimelineEntry {
    let date: Date
    let selection: WidgetSelection
}

struct PingoProvider<Config: WidgetConfigurationIntent & SelectionProviding>: AppIntentTimelineProvider {
    typealias Entry = PingoEntry
    typealias Intent = Config

    let kind: PingoKind

    func placeholder(in context: Context) -> PingoEntry {
        Store.prepare()
        return PingoEntry(date: .now, selection: WidgetSelection())
    }

    func snapshot(for configuration: Config, in context: Context) async -> PingoEntry {
        Store.prepare()
        return PingoEntry(date: .now, selection: configuration.selection)
    }

    func timeline(for configuration: Config, in context: Context) async -> Timeline<PingoEntry> {
        Store.prepare()
        let selection = configuration.selection
        let plan = kind.refresh(albumMinutes: albumMinutes(for: selection)).plan(from: .now)
        let entries = plan.dates.map { PingoEntry(date: $0, selection: selection) }
        return Timeline(entries: entries, policy: .after(plan.reload))
    }

    private func albumMinutes(for selection: WidgetSelection) -> Int? {
        guard kind.usesPhotos else { return nil }
        return Store.albums.resolve(selection)?.minutes
    }
}

struct PingoWidget<Config: WidgetConfigurationIntent & SelectionProviding>: Widget {
    let kind: PingoKind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind.rawValue,
            intent: Config.self,
            provider: PingoProvider<Config>(kind: kind)
        ) { entry in
            PingoWidgetView(kind: kind, entry: entry)
        }
        .configurationDisplayName(kind.title)
        .description(kind.about)
        .supportedFamilies(families)
        .contentMarginsDisabled()
    }

    private var families: [WidgetFamily] {
        kind.sizes.map(\.family) + kind.accessories.map(\.family)
    }
}

struct PingoWidgetView: View {
    let kind: PingoKind
    let entry: PingoEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var mode

    var body: some View {
        content
            .environment(\.layoutDirection, .rightToLeft)
            .widgetURL(kind.link(selection: entry.selection))
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder private var content: some View {
        if let size = family.cardSize {
            kind.face(size: size, date: entry.date, selection: entry.selection)
        } else if let shape = family.accessoryShape {
            kind.accessoryFace(shape: shape, date: entry.date, selection: entry.selection)
        }
    }

    @ViewBuilder private var background: some View {
        if family.cardSize != nil && mode == .fullColor {
            kind.background(selection: entry.selection)
        } else {
            Color.clear
        }
    }
}

extension CardSize {
    var family: WidgetFamily {
        switch self {
        case .small: .systemSmall
        case .medium: .systemMedium
        case .large: .systemLarge
        }
    }
}

extension AccessoryShape {
    var family: WidgetFamily {
        switch self {
        case .circular: .accessoryCircular
        case .rectangular: .accessoryRectangular
        case .inline: .accessoryInline
        }
    }
}

extension WidgetFamily {
    var cardSize: CardSize? {
        switch self {
        case .systemSmall: .small
        case .systemMedium: .medium
        case .systemLarge: .large
        default: nil
        }
    }

    var accessoryShape: AccessoryShape? {
        switch self {
        case .accessoryCircular: .circular
        case .accessoryRectangular: .rectangular
        case .accessoryInline: .inline
        default: nil
        }
    }
}
