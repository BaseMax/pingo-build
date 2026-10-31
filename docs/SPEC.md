# Pingo 1.0 specification

Pingo is a personal iOS widget app (Persian first, RTL, sideloaded with a free Apple account, never on the App Store). The owner wants the whole app finished, with iOS 26 Liquid Glass used heavily and very polished animation. This document is the contract between the people (agents) building it in parallel. Read all of it before writing code.

## 1. Rules that apply to every file

- No comments anywhere: no `//`, no `///`, no `/* */`, in Swift, Metal, YAML, HTML, CSS. Code explains itself through naming. Small functions, atomic views, DRY. Prefer files under about 220 lines; split instead of growing.
- User facing text is Persian, casual and warm ("می‌خوای", "بزن", "انتخاب کن"). English only for things that are not important (tiny technical labels). Never use em dashes or en dashes in any text or string. Use commas and full stops.
- Persian digits come from `Persian.number(_:)` or `Persian.format(_:_:)`. Never format digits by hand.
- The Swift language mode is 5. Deployment target is iOS 18.0. Xcode 26 / Swift 6.2 compiler. Everything iOS 26 only (Liquid Glass) is used ONLY inside `App/Liquid/Glass.swift`, wrapped in `#if compiler(>=6.2)` and `if #available(iOS 26, *)`, with a material fallback. No other file may use `#available`/`#if compiler`.
- No `#Preview` blocks. No `print`. No force unwraps (`!`) except on literals that cannot fail. No third party packages.
- Never run `rm -rf`, never delete files you do not own. Single file `rm` of your own file is fine. The machine blocks destructive commands.
- Do not edit files owned by someone else (section 3). If you need a change there, report it in `needs` in your final result. You may add new files inside your own folders.
- Style of the product: dsto.ir. White paper and ink black, signal orange `#FF5C00`, ocean blue `#1D7FF0`, leaf green `#34C759`, haze greys, big continuous corner radii, font IranYekan X demibold (single weight, build hierarchy with size and opacity, not weight).

## 2. Verification you can actually run (no Xcode here)

The machine is Linux. There is a Swift 6.1 toolchain in docker. Use `scripts/swiftcheck.sh` from the repo root `/home/developer/Projects/BaseMax/pingo`:

- `./scripts/swiftcheck.sh parse` parses every `.swift` file (syntax only). Run it often. It is fast.
- `./scripts/swiftcheck.sh typecheck` type checks every file in `ios/Shared/Logic` together (Foundation only code). 
- `./scripts/swiftcheck.sh test` runs `swift test` for the package `ios/Package.swift` (target `PingoLogic` = `ios/Shared/Logic`, tests in `ios/Tests/PingoLogicTests`). Takes a few minutes.
- `./scripts/swiftcheck.sh` runs all three.
- `./scripts/swiftcheck.sh parse 'Gallery|Library'` parses only files whose path matches the regular expression. Other engineers write files at the same time as you, so the unfiltered run can show errors in files you do not own (half written). Only fix your own files.

Files in `ios/Shared/Logic` must be pure Foundation (no SwiftUI, UIKit, WidgetKit, Observation imports). The only allowed platform touch is `#if canImport(WidgetKit)` in `StoreCore.swift`. They compile on Linux, so write real tests for every non trivial function. SwiftUI, UIKit, WidgetKit and AppIntents code cannot be compiled here, so for those files you must be extremely careful: only use APIs you are certain exist with the exact signature, prefer older stable APIs, and re read your own files against section 11 before finishing. Reviewers will hunt compile errors afterwards.

## 3. Project layout and ownership

Repo root `/home/developer/Projects/BaseMax/pingo`. App sources live in `ios/`. `ios/_legacy/` is the old prototype for reference only (ignore for the build, never edit).

```
ios/Package.swift                         architect
ios/project.yml                           architect
ios/Shared/Logic/Kinds.swift              architect (frozen)
ios/Shared/Logic/Models.swift             architect (frozen)
ios/Shared/Logic/Persian.swift            L2 (additive changes only)
ios/Shared/Logic/MoonPhase.swift          L2
ios/Shared/Logic/DayKey.swift             L1
ios/Shared/Logic/KeyValueBackend.swift    L1
ios/Shared/Logic/AppGroup.swift           L1
ios/Shared/Logic/ItemStore.swift          L1
ios/Shared/Logic/StoreCore.swift          L1
ios/Shared/Logic/Backup.swift             L1
ios/Shared/Logic/HabitMath.swift          L1
ios/Shared/Logic/CounterMath.swift        L1
ios/Shared/Logic/TodoMath.swift           L1
ios/Shared/Logic/FalVerses.swift          L2
ios/Shared/Logic/Fal.swift                L2
ios/Shared/Logic/ClockMath.swift          L2
ios/Shared/Logic/DeepLink.swift           L2
ios/Shared/Logic/Expiry.swift             L2   (ProvisioningProfile and Expiry)
ios/Shared/Platform/PhotoStore.swift      L1
ios/Shared/Platform/LiveItems.swift       L1
ios/Shared/Platform/LiveSettings.swift    L1
ios/Shared/Design/Theme+Style.swift       D2
ios/Shared/Design/Typography.swift        D2
ios/Shared/Design/Environment.swift       D2
ios/Shared/Design/PingoKind+Face.swift    F1
ios/Shared/Design/Faces/*.swift           F1 F2 F3 (see section 12)
ios/Shared/Intents/*.swift                I
ios/Shared/Fonts/DastoYekan.ttf           architect
ios/App/Liquid/Glass.swift, LiquidButtons.swift, LiquidSegmented.swift, LiquidDock.swift, FloatingAddMenu.swift      D1
ios/App/Liquid/Motion.swift, Haptics.swift, MeshBackdrop.swift, Ripple.swift, Ripple.metal, Confetti.swift, TiltParallax.swift   D2
ios/App/Liquid/Layout.swift, LiquidPanel.swift, LiquidFields.swift, LiquidRows.swift, Pickers.swift, EmptyState.swift, SectionTitle.swift, LiquidScreen.swift, LiquidSheetHeader.swift   D3
ios/App/Core/*.swift, ios/App/Onboarding/*.swift     A1
ios/App/Gallery/*.swift                              A2
ios/App/Library/*.swift, ios/App/Editors/NoteEditorView.swift, CountdownEditorView.swift, TodoEditorView.swift   A3
ios/App/Editors/HabitEditorView.swift, CounterEditorView.swift, AlbumEditorView.swift (and helper files named Habit*, Counter*, Album*)   A4
ios/App/Settings/*.swift                              A5
ios/Widgets/*.swift                                   W
ios/Tests/PingoLogicTests/*.swift                     the owner of the logic file under test (name test files after the logic file, for example HabitMathTests.swift)
landing/*                                             LANDING
```

`Shared/**` is compiled into BOTH the app target and the widget extension target. `App/**` only into the app. `Widgets/**` only into the extension. So nothing in `Shared` may reference anything in `App` or `Widgets`, and `Shared/Design` and `Shared/Intents` must not use APIs that are unavailable in widget extensions (no `UIApplication.shared`, no `UIScreen.main` sizing assumptions).

## 4. Logic contract (Foundation only, `ios/Shared/Logic`)

Already written and frozen: `Kinds.swift` (CardSize, AccessoryShape, Theme, PingoCategory, LibraryKind, PingoKind, WidgetSelection, TimelinePlan, Refresh) and `Models.swift` (Appearance, NoteItem, CountdownItem, HabitItem, TodoEntry, TodoList, CounterItem, AlbumItem, AppSettings, Presets). Read them first. All item ids are `String` (UUID strings).

Persian.swift (existing API, keep): `Persian.locale`, `Persian.calendar` (firstWeekday 7), `format(_:_:)`, `number(_:)`, `percent(_:)`, `shift(_:days:)`, `dayNumber(_:)`, `fraction(_:at:)`, `daysBetween(_:_:)`, `monthCells(for:)`. MoonPhase.swift (existing API, keep): `MoonPhase(date:)`, `.fraction`, `.illumination`, `.name`, `.age`.

L1 provides (exact signatures):

```swift
enum DayKey { static func string(_ date: Date) -> String }

protocol KeyValueBackend: AnyObject {
    func data(for key: String) -> Data?
    func set(_ data: Data?, for key: String)
}
final class MemoryBackend: KeyValueBackend { init() }
final class DefaultsBackend: KeyValueBackend { init(_ defaults: UserDefaults) }

enum AppGroup {
    static let identifier: String
    static let defaults: UserDefaults
    static var container: URL
}

struct ItemStore<Item: Codable & Identifiable & Hashable> where Item.ID == String {
    let key: String
    let kind: PingoKind?
    init(key: String, kind: PingoKind?)
    var all: [Item] { get }
    func item(_ id: String) -> Item?
    func resolve(_ selection: WidgetSelection) -> Item?
    func save(_ items: [Item])
    func add(_ item: Item)
    func update(_ id: String, _ body: (inout Item) -> Void)
    func remove(_ id: String)
    func move(from source: IndexSet, to destination: Int)
}

extension Notification.Name { static let pingoStoreChanged: Notification.Name }

enum Store {
    static var backend: KeyValueBackend
    static var onChange: (PingoKind?) -> Void
    static let notes: ItemStore<NoteItem>
    static let countdowns: ItemStore<CountdownItem>
    static let habits: ItemStore<HabitItem>
    static let todos: ItemStore<TodoList>
    static let counters: ItemStore<CounterItem>
    static let albums: ItemStore<AlbumItem>
    static var settings: AppSettings { get set }
    static func theme(for kind: PingoKind) -> Theme
    static func theme(for kind: PingoKind, selection: WidgetSelection) -> Theme
    static func setTheme(_ theme: Theme, for kind: PingoKind)
    static func create(_ kind: LibraryKind) -> String
    static func count(of kind: LibraryKind) -> Int
    static func prepare()
    static func touch(_ kind: PingoKind?)
}
```

Behaviour:
- `resolve(selection)`: the item whose id equals `selection.itemID`, otherwise the first item, otherwise nil.
- `ItemStore.update` re reads from the backend, mutates the one item, saves. Saving calls `Store.touch(kind)`.
- `Store.theme(for:selection:)` order: `selection.theme`, then the resolved item's `theme`, then `settings.kindThemes[kind.rawValue]`, then `kind.defaultTheme`. `Store.theme(for:)` skips the first two.
- `Store.touch(kind)` calls `Store.onChange(kind)`. The default `onChange`, inside `#if canImport(WidgetKit)`, reloads timelines (`WidgetCenter.shared.reloadTimelines(ofKind: kind.rawValue)` or `reloadAllTimelines()` when nil) and posts `.pingoStoreChanged` on the main thread. Without WidgetKit (Linux) the default posts only the notification. The default backend is `DefaultsBackend(AppGroup.defaults)` under `#if canImport(WidgetKit)`, otherwise `MemoryBackend()`. Tests may replace `backend`.
- Changing `Store.settings` calls `onChange(nil)`.
- `Store.create(kind)` appends a new default item with sensible Persian default title (for example habit "عادت جدید", counter "شمارنده جدید", todo "فهرست جدید", countdown title "رویداد جدید" dated 30 days ahead, note empty text, album "آلبوم جدید") and returns its id.
- `Store.prepare()` is idempotent and cheap: if `settings.seeded` is false and all six collections are empty, adds sample items (a note "امروز چه کاری از همه مهم‌تره؟", a countdown "سفر بعدی" 30 days ahead, a habit "ورزش", a todo "کارهای امروز" with three entries, a counter "آب" with goal 8) and sets `seeded = true`.

Item math (L1), all pure and tested:

```swift
extension HabitItem {
    func isDone(_ date: Date) -> Bool
    mutating func toggle(_ date: Date)
    func streak(asOf date: Date) -> Int
    func bestStreak() -> Int
    func rate(lastDays: Int, asOf date: Date) -> Double
    func lastDays(_ count: Int, asOf date: Date) -> [Date]
}
extension CounterItem {
    func count(on date: Date) -> Int
    func progress(on date: Date) -> Double
    func reachedGoal(on date: Date) -> Bool
    var total: Int { get }
    mutating func step(by delta: Int, on date: Date)
    func history(_ days: Int, asOf date: Date) -> [(day: Date, count: Int)]
}
extension TodoList {
    var doneCount: Int { get }
    var remaining: Int { get }
    mutating func toggle(_ itemID: String)
    mutating func add(_ text: String)
    mutating func clearDone()
}
```
`CounterItem.count(on:)` always reads `counts[DayKey.string(date)]`; `dailyReset` only affects what the UI shows as "today" versus lifetime `total`; `step` never goes below 0.

Backup (L1):

```swift
struct Backup: Codable {
    var version: Int
    var exportedAt: Date
    var notes: [NoteItem]; var countdowns: [CountdownItem]; var habits: [HabitItem]
    var todos: [TodoList]; var counters: [CounterItem]; var albums: [AlbumItem]
    var settings: AppSettings
    var photos: [String: Data]
    static func make(photoLoader: (String) -> Data?) -> Backup
    func encoded() throws -> Data
    static func decoded(from data: Data) throws -> Backup
    func restore(photoSaver: (String, Data) -> Void)
}
```
`make` reads from `Store`, `restore` replaces all collections and settings (keeping `onboarded`), saving photo bytes through `photoSaver(fileName, data)`.

L2 provides:

```swift
struct FalVerse: Hashable { let first: String; let second: String; let poet: String }
enum Fal {
    static let verses: [FalVerse]
    static func verse(on date: Date, seed: Int) -> FalVerse
}
enum ClockMath {
    static func hourAngle(_ date: Date, calendar: Calendar) -> Double
    static func minuteAngle(_ date: Date, calendar: Calendar) -> Double
    static func digital(_ date: Date, calendar: Calendar) -> String
}
struct ItemRoute: Hashable { let kind: LibraryKind; let id: String }
enum Route: Hashable {
    case kind(PingoKind)
    case item(ItemRoute)
    case library(LibraryKind?)
    case settings
    case guide(PingoKind?)
    init?(url: URL)
    var url: URL { get }
}
struct ProvisioningProfile: Equatable {
    let name: String?
    let teamID: String?
    let expirationDate: Date?
    let groups: [String]
    static func parse(_ data: Data) -> ProvisioningProfile?
    static func embedded(in bundle: Bundle) -> ProvisioningProfile?
}
enum ExpiryLevel: Equatable { case unknown, healthy, soon, expired }
struct ExpiryStatus: Equatable {
    let level: ExpiryLevel
    let daysLeft: Int
    let fractionLeft: Double
    let message: String
}
enum Expiry {
    static let lifetimeDays: Int
    static func status(expiry: Date?, now: Date) -> ExpiryStatus
    static func reminderDates(expiry: Date, now: Date) -> [Date]
}
```
Route URLs: `pingo://kind/<PingoKind.rawValue>`, `pingo://item/<LibraryKind.rawValue>/<id>`, `pingo://library` and `pingo://library/<LibraryKind.rawValue>`, `pingo://settings`, `pingo://guide` and `pingo://guide/<PingoKind.rawValue>`. Parsing returns nil for anything else. `Fal.verse(on:seed:)` is deterministic: same Persian day plus seed gives the same verse, the index changes with the day and with the seed. `Expiry.lifetimeDays` is 7. Reminder dates: 24 hours and 3 hours before expiry, only those still in the future. AppGroup (L1) uses `ProvisioningProfile.embedded(in: .main)?.groups.first` first, then the Info.plist key `PingoGroup`, then `"group.ir.dsto.pingo"`.

`Refresh.plan(from:)` and `PingoKind.refresh(albumMinutes:)` already exist in `Kinds.swift`; L2 adds tests for them.

## 5. Platform contract (`ios/Shared/Platform`, Apple frameworks, no SwiftUI views)

L1 provides:

```swift
enum PhotoStore {
    static func save(_ data: Data) -> String?
    static func image(named name: String, maxSide: CGFloat) -> UIImage?
    static func thumbnail(named name: String, side: CGFloat) -> UIImage?
    static func data(named name: String) -> Data?
    static func exists(_ name: String) -> Bool
    static func remove(_ name: String)
}
```
Files live in `AppGroup.container/photos/`. `save` downsamples with ImageIO to at most 1000 px on the long side, writes JPEG quality 0.85, returns a new unique file name (for example `UUID().uuidString + ".jpg"`). `image(named:maxSide:)` and `thumbnail` decode with `CGImageSourceCreateThumbnailAtIndex` so widget memory stays small.

```swift
@MainActor @Observable final class LiveItems<Item: Codable & Identifiable & Hashable> where Item.ID == String {
    private(set) var items: [Item]
    init(_ store: ItemStore<Item>)
    func reload()
    func add(_ item: Item)
    func update(_ id: String, _ body: (inout Item) -> Void)
    func remove(_ id: String)
    func move(from source: IndexSet, to destination: Int)
}
@MainActor @Observable final class LiveSettings {
    static let shared: LiveSettings
    var value: AppSettings
    func reload()
}
extension View { func reloadsOnActive(_ reload: @escaping @MainActor () -> Void) -> some View }
```
`LiveItems` and `LiveSettings` reload themselves when `.pingoStoreChanged` is posted and expose `reload()` for scene activation; setting `LiveSettings.value` writes through to `Store.settings` when it changes. `reloadsOnActive` runs the closure whenever `scenePhase` becomes `.active` (and once on appear).

## 6. Design contract (`ios/Shared/Design`, SwiftUI, used by app AND widgets)

D2 provides:

```swift
extension Color {
    init(hex: UInt32)
    static let signal: Color
    static let ocean: Color
    static let leaf: Color
}
extension Theme {
    var colors: [Color] { get }
    var ink: Color { get }
    var soft: Color { get }
    var track: Color { get }
    var accent: Color { get }
    var onAccent: Color { get }
    var rings: [Color] { get }
    var background: some View { get }
}
extension View { func dasto(_ size: CGFloat) -> some View }
extension EnvironmentValues { var animates: Bool { get set } }
```
Theme palette (same as the prototype in `ios/_legacy/Shared/Theme.swift`): paper `FFFFFF to F1F1F4`, haze `F2F2F7 to DADAE2`, sand `F6EBD3 to EBDBB8`, signal `FF8A3D to FF5C00`, sky `45B5FF to 1D7FF0`, leaf `66E38A to 2FBF5B`, ink `2C2C2E to 000000`. `dasto(_:)` is `font(.custom("IRANYekanXNoEn-DemiBold", fixedSize: size))`. The font file is registered through `UIAppFonts` in both Info.plists (already in project.yml).

Faces (F1 F2 F3). Every face is a `View` struct taking value types and a `Theme`, draws its content filling the card, applies its own padding (the widget uses `contentMarginsDisabled`), has NO background (the container supplies it), and handles a missing item (nil) with a friendly empty state in Persian. Faces must look right at the exact `CardSize.points` of each supported size and must not use `GeometryReader` tricks that break in widgets. Signatures:

```swift
DateFace(date: Date, size: CardSize, theme: Theme, showsGregorian: Bool)
ClockFace(date: Date, size: CardSize, theme: Theme)
ProgressFace(date: Date, size: CardSize, theme: Theme)
CountdownFace(item: CountdownItem?, date: Date, size: CardSize, theme: Theme)
MoonFace(phase: MoonPhase, size: CardSize, theme: Theme)
NoteFace(item: NoteItem?, size: CardSize, theme: Theme)
TodoFace(list: TodoList?, size: CardSize, theme: Theme)
HabitFace(item: HabitItem?, date: Date, size: CardSize, theme: Theme)
CounterFace(item: CounterItem?, date: Date, size: CardSize, theme: Theme)
PhotoFace(album: AlbumItem?, date: Date, size: CardSize, theme: Theme)
FalFace(date: Date, seed: Int, size: CardSize, theme: Theme)

DateAccessory(date: Date, shape: AccessoryShape, showsGregorian: Bool)
ClockAccessory(date: Date)
ProgressAccessory(date: Date, shape: AccessoryShape)
CountdownAccessory(item: CountdownItem?, date: Date, shape: AccessoryShape)
MoonAccessory(phase: MoonPhase)
HabitAccessory(item: HabitItem?, date: Date)
CounterAccessory(item: CounterItem?, date: Date)
```

F1 also writes the dispatcher in `PingoKind+Face.swift`:

```swift
extension PingoKind {
    @ViewBuilder func face(size: CardSize, date: Date, selection: WidgetSelection) -> some View
    @ViewBuilder func accessoryFace(shape: AccessoryShape, date: Date, selection: WidgetSelection) -> some View
    func background(selection: WidgetSelection) -> some View
    func link(selection: WidgetSelection) -> URL
}
```
`face` resolves data from `Store` (`Store.notes.resolve(selection)` and so on, `Store.settings.showsGregorian`, `Store.settings.falSeed`), picks `Store.theme(for: self, selection: selection)`, and builds the matching face. `background` returns the theme gradient, or solid black for `.photo`. `link` builds the widget tap URL from `Route`: for kinds with a library item `Route.item(ItemRoute(kind: library, id: resolved id))` when an item exists, otherwise `Route.kind(self)`.

Widget rendering modes: faces read `@Environment(\.widgetRenderingMode)`. In `.accented` or `.vibrant` mode use `Color.primary` style foregrounds and wrap the accent elements in `.widgetAccentable()`; in `.fullColor` (default, and in the app where the value is not set) use the theme colors. Accessory faces always use system styles (`.primary`, `.secondary`), `Gauge`, `.widgetAccentable()`, and `AccessoryWidgetBackground()` where a background is wanted.

Interactive faces call these intents (defined by I in `Shared/Intents`) with `Button(intent:)`:

```swift
ToggleHabitIntent(habitID: String)
CounterStepIntent(counterID: String, delta: Int)
ToggleTodoIntent(listID: String, itemID: String)
NewFalIntent()
```

Animation inside faces: rings and bars animate in only when `@Environment(\.animates)` is true (the app sets it, widgets do not). Use `contentTransition(.numericText())` for numbers and `symbolEffect` where it helps. Nothing in a face may depend on state that WidgetKit cannot render statically.

## 7. Liquid layer contract (`ios/App/Liquid`, app only)

D2, Motion tokens and effects:

```swift
extension Animation {
    static var liquid: Animation { get }
    static var liquidSoft: Animation { get }
    static var liquidSnap: Animation { get }
    static var liquidStretch: Animation { get }
}
struct BlurFade: ViewModifier { init(hidden: Bool, radius: CGFloat = 14, scale: CGFloat = 0.97) }
extension AnyTransition { static var blurFade: AnyTransition { get } }
extension View {
    func reveal(_ delay: Double = 0) -> some View
    func scrollBlur() -> some View
    func rubberBand() -> some View
    func pingRipple() -> some View
    func tiltParallax(_ strength: CGFloat = 1) -> some View
}
struct Pressable: ButtonStyle { init() }
enum Haptics {
    static func tap()
    static func soft()
    static func selection()
    static func success()
    static func warning()
}
struct MeshBackdrop: View { init() }
struct ConfettiBurst: View { init(trigger: Int) }
```
Values: `liquid = .spring(duration: 0.55, bounce: 0.28)`, `liquidSoft = .smooth(duration: 0.8)`, `liquidSnap = .snappy(duration: 0.35)`, `liquidStretch = .spring(duration: 0.7, bounce: 0.5)`. `Haptics` reads `Store.settings.haptics` before firing. `MeshBackdrop` is an animated `MeshGradient` (3x3, points drift slowly with sin/cos driven by `TimelineView(.animation)`) tinted with the dsto palette, aware of light and dark (`@Environment(\.colorScheme)`), static when `accessibilityReduceMotion` is on. `pingRipple()` adds a Metal `layerEffect` ripple that starts where the finger touched (the app is called Pingo, a ping is a ripple). `Ripple.metal` contains one `[[ stitchable ]]` function named `Ripple`. `tiltParallax` uses CoreMotion device motion for a small 3D tilt and a moving specular highlight, disabled under reduce motion. `rubberBand()` is the elastic drag from the prototype (see `ios/_legacy/App/Motion.swift`). `ConfettiBurst` is a Canvas particle burst (colors from the dsto palette) replayed whenever `trigger` changes.

D1, Glass and controls:

```swift
extension View {
    func glass<S: Shape>(_ shape: S, tint: Color? = nil, interactive: Bool = false) -> some View
    func glassCapsule(tint: Color? = nil, interactive: Bool = false) -> some View
    func glassCircle(tint: Color? = nil, interactive: Bool = false) -> some View
    func glassID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View
}
struct GlassGroup<Content: View>: View { init(spacing: CGFloat = 12, @ViewBuilder _ content: () -> Content) }
struct LiquidButtonStyle: ButtonStyle { init(prominent: Bool = false, tint: Color? = nil) }
extension ButtonStyle where Self == LiquidButtonStyle {
    static var liquid: LiquidButtonStyle { get }
    static var liquidProminent: LiquidButtonStyle { get }
}
struct LiquidIconButton: View { init(symbol: String, tint: Color? = nil, action: @escaping () -> Void) }
struct LiquidSegmented<Value: Hashable>: View {
    init(_ items: [Value], selection: Binding<Value>, title: @escaping (Value) -> String)
}
enum AppTab: String, CaseIterable, Identifiable { case gallery, library, settings }
struct LiquidDock: View { init(selection: Binding<AppTab>) }
struct FloatingAction: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let tint: Color
    let perform: () -> Void
}
struct FloatingAddMenu: View { init(actions: [FloatingAction]) }
```
`AppTab` has `title` ("ویجت‌ها", "کتابخانه", "تنظیمات") and `symbol` ("square.grid.2x2.fill", "tray.full.fill", "gearshape.fill"). On iOS 26 `glass` uses `glassEffect(.regular.tint(...).interactive(...), in: shape)`, `GlassGroup` is `GlassEffectContainer`, `glassID` is `glassEffectID`; before iOS 26 `glass` is `ultraThinMaterial` plus a white hairline stroke and soft shadow, `GlassGroup` is a plain group and `glassID` is a no op. `LiquidDock` is a floating glass capsule near the bottom (padding 16, above the home indicator): the selected item is a glass pill that slides to the new tab and stretches (scaleX overshoot, squash) on the way, labels fade in for the selected tab only, symbols bounce, selection haptic. `FloatingAddMenu` is a glass circle "+" that morphs into a vertical stack of glass pills (staggered spring, blur fade), dimming and blurring what is behind, closing on any tap outside.

D3, Layout and form components:

```swift
enum Layout {
    static let gutter: CGFloat
    static let corner: CGFloat
    static let heroCorner: CGFloat
    static let dockClearance: CGFloat
}
extension View {
    func panel() -> some View
    func liquidScreen() -> some View
}
struct LiquidPanel<Content: View>: View { init(@ViewBuilder _ content: () -> Content) }
struct LiquidTextField: View { init(_ placeholder: String, text: Binding<String>, symbol: String? = nil) }
struct LiquidTextArea: View { init(_ placeholder: String, text: Binding<String>, minHeight: CGFloat = 140) }
struct LiquidToggleRow: View { init(_ title: String, symbol: String? = nil, isOn: Binding<Bool>) }
struct LiquidStepperRow: View {
    init(_ title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int = 1, format: ((Int) -> String)? = nil)
}
struct ThemePickerRow: View { init(selection: Binding<Theme?>, automaticTitle: String = "خودکار") }
struct KindThemePickerRow: View { init(selection: Binding<Theme>) }
struct SymbolPickerRow: View { init(_ symbols: [String], selection: Binding<String>) }
struct LiquidDateRow: View { init(_ title: String, date: Binding<Date>) }
struct EmptyState: View {
    init(symbol: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil)
}
struct SectionTitle: View { init(_ title: String, symbol: String? = nil) }
struct LiquidRow<Leading: View, Trailing: View>: View {
    init(title: String, subtitle: String? = nil, @ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing)
}
struct LiquidSheetHeader: View { init(_ title: String, onClose: @escaping () -> Void) }
```
`Layout`: gutter 16, corner 28, heroCorner 44, dockClearance 104. `panel()` pads 16 and backs the content with a solid rounded rectangle (continuous, `Layout.corner`) using `Color(.secondarySystemGroupedBackground)`. `liquidScreen()` puts `MeshBackdrop` behind the content, clears list and scroll backgrounds (`scrollContentBackground(.hidden)`), and reserves `Layout.dockClearance` at the bottom with a `safeAreaInset`. Content cards stay SOLID (panels). Glass is for the controls layer only.

## 8. Intents and widgets contract

I (`ios/Shared/Intents`, AppIntents, compiled into both targets):

```swift
enum ThemeChoice: String, AppEnum, CaseIterable {
    case automatic, paper, haze, sand, signal, sky, leaf, ink
    var theme: Theme? { get }
}
struct NoteEntity: AppEntity, Identifiable       struct NoteQuery: EntityQuery
struct CountdownEntity: AppEntity, Identifiable  struct CountdownQuery: EntityQuery
struct HabitEntity: AppEntity, Identifiable      struct HabitQuery: EntityQuery
struct TodoEntity: AppEntity, Identifiable       struct TodoQuery: EntityQuery
struct CounterEntity: AppEntity, Identifiable    struct CounterQuery: EntityQuery
struct AlbumEntity: AppEntity, Identifiable      struct AlbumQuery: EntityQuery

protocol SelectionProviding { var selection: WidgetSelection { get } }
struct ThemeConfigIntent: WidgetConfigurationIntent, SelectionProviding
struct NoteConfigIntent: WidgetConfigurationIntent, SelectionProviding
struct CountdownConfigIntent: WidgetConfigurationIntent, SelectionProviding
struct HabitConfigIntent: WidgetConfigurationIntent, SelectionProviding
struct TodoConfigIntent: WidgetConfigurationIntent, SelectionProviding
struct CounterConfigIntent: WidgetConfigurationIntent, SelectionProviding
struct AlbumConfigIntent: WidgetConfigurationIntent, SelectionProviding

struct ToggleHabitIntent: AppIntent      init(habitID: String)
struct CounterStepIntent: AppIntent      init(counterID: String, delta: Int)
struct ToggleTodoIntent: AppIntent       init(listID: String, itemID: String)
struct NewFalIntent: AppIntent           init()
struct ToggleFirstHabitIntent: AppIntent init()
struct CountFirstCounterIntent: AppIntent init()
```
Entity ids are the item ids. Every `*ConfigIntent` has an optional entity parameter (except `ThemeConfigIntent`) and a `theme: ThemeChoice` parameter with default `.automatic`; `selection` maps them to `WidgetSelection(itemID:, theme:)`. Entity queries read the collections in `Store`; `suggestedEntities()` returns all items, `defaultResult()` the first. The action intents mutate `Store` through `ItemStore.update` and are not discoverable (`isDiscoverable = false`). `ToggleHabitIntent` toggles today, `CounterStepIntent` adds `delta * step` clamped at 0, `ToggleTodoIntent` toggles the entry, `NewFalIntent` increments `settings.falSeed`. `ToggleFirstHabitIntent` and `CountFirstCounterIntent` are parameter free versions used by Control Center controls.

W (`ios/Widgets`): `PingoWidgets.swift` is the `@main WidgetBundle` containing eleven widgets (one per `PingoKind`, kind string `kind.rawValue`) and two controls; `PingoWidget.swift` has the generic widget, an `AppIntentTimelineProvider` generic over `SelectionProviding` intents, the entry type (`date` and `selection`), and the view that renders `kind.face(...)`, `kind.accessoryFace(...)`, `.widgetURL(kind.link(...))` and `.containerBackground(for: .widget) { kind.background(selection:) }` (clear background in accented/vibrant rendering modes and for accessory families); `Controls.swift` has `ControlWidget`s for toggling the first habit and counting the first counter using `ToggleFirstHabitIntent` and `CountFirstCounterIntent`. Supported families come from `kind.sizes` and `kind.accessories`. Timelines come from `kind.refresh(albumMinutes:).plan(from:)`. Widgets call `Store.prepare()` before reading. Placeholder and snapshot use the same face with sample friendly data.

## 9. App contract (`ios/App`)

A1 provides `PingoApp` (@main), `AppRouter`, `RootView`, `OnboardingView`:

```swift
@MainActor @Observable final class AppRouter {
    var tab: AppTab
    var galleryPath: NavigationPath
    var libraryPath: NavigationPath
    var sheet: AppSheet?
    func open(_ route: Route)
    func handle(_ url: URL)
}
enum AppSheet: Identifiable, Hashable { case guide(PingoKind?) }
struct RootView: View
struct OnboardingView: View { init(onFinish: @escaping () -> Void) }
```
`open(.kind(k))` selects the gallery tab and appends `k` to `galleryPath`; `open(.item(r))` selects the library tab and appends `r` to `libraryPath`; `open(.library(_))` selects the library tab; `open(.settings)` selects settings; `open(.guide(k))` sets `sheet`. The router is injected with `.environment(router)` and read with `@Environment(AppRouter.self)`. `PingoApp` calls `Store.prepare()`, applies `LiveSettings.shared.value.appearance` with `preferredColorScheme`, forces `layoutDirection` right to left and `locale` `Persian.locale`, tints with `Color.signal`, handles `onOpenURL`, shows `OnboardingView` first when `onboarded` is false (then sets it true), and presents the guide sheet. `RootView` puts `MeshBackdrop` behind the three tab roots (kept alive, switched with blur fade) and `LiquidDock` floating above them.

A2 (`ios/App/Gallery`): `GalleryView()` (a `NavigationStack(path: $router.galleryPath)` with categories from `PingoCategory`, search, a grid of `KindCard`s with live face previews, `navigationDestination(for: PingoKind.self)` to `KindDetailView(kind:)` with a zoom transition from the card, and `navigationDestination(for: ItemRoute.self)` to `ItemEditorView(route:)`), `KindCard`, `KindDetailView(kind: PingoKind)` (big live preview with rubber band and tilt, size picker via `LiquidSegmented`, lock screen shapes preview, `KindThemePickerRow`, kind options such as the Gregorian toggle for the date widget, an items section listing the library items of that kind with add and open, a button that opens the guide), and

```swift
struct FacePreview: View { init(kind: PingoKind, size: CardSize, selection: WidgetSelection = WidgetSelection()) }
struct AccessoryPreview: View { init(kind: PingoKind, shape: AccessoryShape, selection: WidgetSelection = WidgetSelection()) }
```
`FacePreview` renders `kind.face(...)` at `size.points` with the theme background, continuous clip (radius 26 for small and medium, matching widgets), soft shadow, `animates = true`, refreshes on `.pingoStoreChanged` and scene activation.

A3 (`ios/App/Library`, three editors): `LibraryView()` (a `NavigationStack(path: $router.libraryPath)`, sections per `LibraryKind` with counts, rows with swipe delete and reorder, `FloatingAddMenu` creating items with `Store.create` then `router.open(.item(...))`, empty states), `ItemEditorView(route: ItemRoute)` which switches on `route.kind` to the six editors, and `NoteEditorView(id: String)`, `CountdownEditorView(id: String)`, `TodoEditorView(id: String)`. A4 provides `HabitEditorView(id: String)`, `CounterEditorView(id: String)`, `AlbumEditorView(id: String)`. Every editor edits one item through a local `@State` draft, writes back with `Store.<collection>.update(id)` on change (never overwriting the whole list), shows a live `FacePreview` of the matching widget at the top, uses `ThemePickerRow`, handles a deleted item (dismiss), and reloads on scene activation.

A5 (`ios/App/Settings`): `SettingsView()` (NavigationStack, install validity card with a ring and days left from `ProvisioningProfile.embedded(in: .main)` and `Expiry.status`, reminder toggle that schedules local notifications from `Expiry.reminderDates` through a `ReminderScheduler`, haptics toggle, appearance via `LiquidSegmented`, backup export and import with `fileExporter` and `fileImporter` using `Backup`, `PhotoStore`, data summary, reset, about with version, and a link to the guide) and

```swift
struct GuideSheet: View { init(kind: PingoKind? = nil) }
enum ReminderScheduler { static func refresh() async }
```
`GuideSheet` explains adding a widget to the Home Screen and Lock Screen with animated steps (kind specific tip when `kind` is not nil) and the seven day renewal rule.

## 10. Visual and motion language (the owner cares about this most)

- Liquid Glass on the CONTROL layer: dock, floating add menu, toolbar and close buttons, segmented controls and their sliding pill, small floating badges. Content (cards, rows, editors) is solid and calm. Group adjacent glass shapes in `GlassGroup` so they merge and morph.
- A `MeshBackdrop` lives behind everything, subtle, so the glass has something to refract. Light mode: near white with pastel orange, blue and green glows. Dark mode: near black with deeper glows.
- Every state change animates, using only the tokens `liquid`, `liquidSoft`, `liquidSnap`, `liquidStretch`. Appearing content uses blur and fade (opacity, blur 14, scale 0.97) staggered 60 to 90 ms with `.reveal(delay)`. Scroll content uses `.scrollBlur()`. Presses scale to 0.94 with a light blur and a haptic (`Pressable` or `LiquidButtonStyle`). Selection pills stretch and settle. Numbers use `contentTransition(.numericText())`. Symbols use `symbolEffect` on change. Drags are rubber band. Card to detail uses `navigationTransition(.zoom)` with `matchedTransitionSource`. Menus and sheets morph from their source. Deleting collapses with blur out. Success moments (habit done, counter goal reached, todo completed) fire `ConfettiBurst` and `Haptics.success()`.
- Reduce motion: when `accessibilityReduceMotion` is true there is no mesh drift, ripple, tilt or confetti and springs are replaced by short fades.
- Large continuous corner radii (28 panels, 44 hero cards), 16 point gutters, generous vertical rhythm, one weight of type with size and opacity for hierarchy, Persian right to left everywhere (use leading and trailing, never left and right).

## 11. Apple API notes (avoid compile errors)

- Observation: `@Observable` classes, `@Bindable` for bindings to them, `@Environment(Type.self)` for environment objects. UI models are `@MainActor`.
- `onChange(of:)` uses the two parameter closure `{ old, new in }`. `NavigationStack` only. `ForEach` over `Identifiable` or with explicit `id`. Use `Tab`-free custom dock (no `TabView`).
- `MeshGradient(width:height:points:colors:)` with `[SIMD2<Float>]` and `[Color]` (iOS 18). `TimelineView(.animation)`. `PhaseAnimator`, `KeyframeAnimator` (iOS 17). `scrollTransition`, `visualEffect`, `sensoryFeedback`, `contentTransition`, `symbolEffect`.
- Metal: file `Ripple.metal` includes `<metal_stdlib>` and `<SwiftUI/SwiftUI_Metal.h>`, `using namespace metal;`, signature `[[ stitchable ]] half4 Ripple(float2 position, SwiftUI::Layer layer, float2 origin, float time, float amplitude, float frequency, float decay, float speed)`. Swift side `ShaderLibrary.Ripple(.float2(origin), .float(time), .float(amplitude), .float(frequency), .float(decay), .float(speed))` and `.layerEffect(shader, maxSampleOffset: CGSize(width: amplitude, height: amplitude))`.
- Charts: `import Charts`, `Chart { BarMark(x: .value("روز", day, unit: .day), y: .value("تعداد", count)) }`.
- Photos: `PhotosPicker(selection: $items, maxSelectionCount: 12, matching: .images)` with `[PhotosPickerItem]`; load with `try await item.loadTransferable(type: Data.self)`.
- Files: a `FileDocument` struct with `static var readableContentTypes: [UTType] { [.json] }`, `.fileExporter(isPresented:document:contentType:defaultFilename:onCompletion:)`, `.fileImporter(isPresented:allowedContentTypes:onCompletion:)`, wrap reads in `url.startAccessingSecurityScopedResource()`.
- Notifications: `UNUserNotificationCenter.current()`, `requestAuthorization(options:)`, `UNMutableNotificationContent`, `UNCalendarNotificationTrigger(dateMatching:repeats:)`.
- AppIntents: `AppEntity` needs `static let typeDisplayRepresentation: TypeDisplayRepresentation`, `static let defaultQuery = Query()`, `var id: String`, `var displayRepresentation: DisplayRepresentation`. `EntityQuery` needs `func entities(for identifiers: [String]) async throws -> [Entity]` and `func suggestedEntities() async throws -> [Entity]`. `WidgetConfigurationIntent` needs `static let title: LocalizedStringResource`, `static let description = IntentDescription("...")` and `init()`. Parameters: `@Parameter(title: "عنوان") var x: Entity?` and `@Parameter(title: "رنگ", default: .automatic) var theme: ThemeChoice`. `AppEnum` needs `static let typeDisplayRepresentation` and `static let caseDisplayRepresentations: [Self: DisplayRepresentation]`. Action intents: `static let title: LocalizedStringResource`, `static let isDiscoverable = false`, `func perform() async throws -> some IntentResult`, `@Parameter` properties plus a custom init that sets them and an empty `init()`.
- WidgetKit: `AppIntentConfiguration(kind:intent:provider:content:)`, `AppIntentTimelineProvider` (`placeholder(in:)`, `snapshot(for:in:) async`, `timeline(for:in:) async`), `.configurationDisplayName`, `.description`, `.supportedFamilies`, `.contentMarginsDisabled()`, `.containerBackground(for: .widget)`, `.widgetURL`, `.widgetAccentable()`, `@Environment(\.widgetRenderingMode)`, `Gauge` with `.gaugeStyle(.accessoryCircular)`, `ControlWidget` with `StaticControlConfiguration(kind:) { ControlWidgetButton(action: Intent()) { Label(...) } }.displayName(...).description(...)`.
- iOS 26 Glass (only in `Glass.swift`): `glassEffect(_ glass: Glass = .regular, in: some Shape)`, `Glass.regular.tint(_:).interactive(_:)`, `GlassEffectContainer(spacing:content:)`, `glassEffectID(_:in:)`.
- Forced right to left: `.environment(\.layoutDirection, .rightToLeft)` at the app root and inside every face and preview (widgets do not inherit it).

## 12. Assignments

Wave 1 (foundation, parallel): 
- L1: DayKey, KeyValueBackend, AppGroup, ItemStore, StoreCore, Backup, HabitMath, CounterMath, TodoMath, PhotoStore, LiveItems, LiveSettings, plus tests for everything testable.
- L2: Persian (additive), MoonPhase tests, FalVerses and Fal (at least 40 well known Hafez couplets that you are completely sure of, word for word; skip any you doubt), ClockMath, DeepLink, Expiry with ProvisioningProfile, plus tests including `Refresh.plan` and `PingoKind.refresh`.
- D1: Glass, LiquidButtons, LiquidSegmented, LiquidDock (with AppTab), FloatingAddMenu.
- D2: Theme+Style, Typography, Environment, Motion, Haptics, MeshBackdrop, Ripple.swift and Ripple.metal, Confetti, TiltParallax.
- D3: Layout, LiquidPanel, LiquidFields, LiquidRows, Pickers, EmptyState, SectionTitle, LiquidScreen, LiquidSheetHeader.

Wave 2 (features, parallel, after Wave 1 exists on disk so read the real code): I, F1, F2, F3, W, A1, A2, A3, A4, A5, LANDING.
- F1: `PingoKind+Face.swift` dispatcher, DateFace (small, medium, large month grid with Gregorian line), ClockFace (analog and digital), ProgressFace, DateAccessory, ClockAccessory, ProgressAccessory.
- F2: CountdownFace, MoonFace, NoteFace, PhotoFace (slideshow picks the photo by entry date: `index = Int(date.timeIntervalSince1970 / (album.minutes * 60)) % album.photos.count`, images via `PhotoStore.image(named:maxSide:)`), CountdownAccessory, MoonAccessory.
- F3: TodoFace (interactive checkboxes), HabitFace (interactive, week dots), CounterFace (interactive plus and minus with a goal ring), FalFace (verse, poet, interactive "فال جدید" button), HabitAccessory, CounterAccessory.
- LANDING: updates `landing/` to present all eleven widgets and the new features.

## 13. What to return

Finish by returning the structured result requested in your prompt: a short summary, the list of files you created or changed, the exact public signatures you implemented where they differ from this document, the checks you ran with their result, and a `needs` list of changes you require from files you do not own. Be honest about anything you could not verify.

## 14. Wave 2 addendum (Wave 1 is finished and on disk, read the real code, it wins over this document)

What Wave 1 actually built, beyond or different from the contract:
- `Haptics` is `@MainActor`. Call it from view code and button actions only.
- `PhotoStore.write(_ data: Data, named name: String) -> Bool` exists (restore under an old file name). Backup export is `Backup.make { PhotoStore.data(named: $0) }` and restore is `backup.restore { PhotoStore.write($1, named: $0) }`.
- `DayKey.date(_:)`, `Backup.currentVersion`, `BackupError.unsupportedVersion`, `Route.scheme`, `Expiry.soonDays`, `Persian.weekdayLetters`, `weekdayOffset(_:)`, `weekdayLetter(_:)`, `weekdayName(_:)`, `monthName(_:)`, `monthTitle(_:)`, `shortDate(_:)`, `relativeDay(_:from:)` exist. Read `Persian.swift` before writing date text.
- D3 row components (`LiquidToggleRow`, `LiquidStepperRow`, `LiquidDateRow`, `SymbolPickerRow`, `LiquidRow`, `ThemePickerRow`, `KindThemePickerRow`) draw their own solid card. Do not wrap them in another `panel()`. `LiquidTextField` and `LiquidTextArea` have their own chrome as well. `PanelBackground(corner:)` and `RowSymbolTile(symbol:)` are reusable.
- `StretchPill.swift` (D1) holds the shared stretch and squash keyframe used by the dock and the segmented control.
- `rubberBand()` only reacts to horizontally dominant drags (so it never fights vertical scrolling).
- `Store.setTheme` calls `onChange(kind)`. `Store.prepare()` seeds sample items once.

New contracts for Wave 2:

F1 owns `ios/Shared/Design/FacePalette.swift` and `FaceEmpty.swift` and F2, F3, F1 all use them:

```swift
struct FacePalette {
    let theme: Theme
    let isFullColor: Bool
    init(theme: Theme, mode: WidgetRenderingMode)
    var ink: Color { get }
    var soft: Color { get }
    var track: Color { get }
    var accent: Color { get }
    var onAccent: Color { get }
    var rings: [Color] { get }
}
extension View { func faceAccent() -> some View }
struct FaceEmpty: View { init(symbol: String, title: String, palette: FacePalette) }
```
In full color mode the palette mirrors `Theme` (ink, soft, track, accent, onAccent, rings). In `.accented` and `.vibrant` mode ink is `Color.primary`, soft is `Color.secondary`, track is `Color.primary.opacity(0.18)`, accent is `Color.primary`, onAccent is `Color.clear`... choose sensible values, `rings` are primary at decreasing opacity. `faceAccent()` applies `widgetAccentable()` (a no op outside widgets). Faces declare `@Environment(\.widgetRenderingMode) private var mode` and `private var palette: FacePalette { FacePalette(theme: theme, mode: mode) }`. `FaceEmpty` is a centered symbol (size 30) plus a short Persian line, used by every face when its item is nil.

A5 owns `ReminderScheduler` with exactly:

```swift
enum ReminderScheduler {
    static func refresh() async
    static func requestAuthorization() async -> Bool
}
```

Other Wave 2 rules: widgets cannot animate with state, so faces must render correctly as a static snapshot. Interactive controls inside faces are only `Button(intent:)` with the intents of section 8. Every `*Face` must lay out inside exactly `size.points` (small 158x158, medium 338x158, large 338x354), with 16 point padding, and nothing may be clipped.
