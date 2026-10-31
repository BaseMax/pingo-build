import SwiftUI

struct LibraryView: View {
    @Environment(AppRouter.self) private var router
    @State private var collections = LibraryCollections()
    @State private var editMode = EditMode.inactive

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.libraryPath) {
            content
                .navigationTitle("کتابخانه")
                .navigationBarTitleDisplayMode(.large)
                .toolbar { toolbarItems }
                .navigationDestination(for: ItemRoute.self) { route in
                    ItemEditorView(route: route)
                }
        }
    }

    private var isEmpty: Bool {
        collections.isEmpty(showing: router.libraryFilter)
    }

    private var content: some View {
        Group {
            if isEmpty {
                emptyState.transition(.blurFade)
            } else {
                LibraryList(collections: collections, filter: router.libraryFilter)
                    .environment(\.editMode, $editMode)
                    .transition(.blurFade)
            }
        }
        .animation(.liquid, value: isEmpty)
        .liquidScreen()
        .reloadsOnActive { collections.reloadAll() }
    }

    private var emptyState: some View {
        let kind = router.libraryFilter ?? .note
        return EmptyState(
            symbol: router.libraryFilter?.symbol ?? "tray.full.fill",
            title: router.libraryFilter.map { $0.plural + " خالیه" } ?? "کتابخانه‌ت خالیه",
            message: "هر چی ویجت‌هات نشون می‌دن اینجا جمع می‌شه. یکی بساز تا شروع کنیم.",
            actionTitle: kind.title + " جدید",
            action: { router.createItem(kind) }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        if router.libraryFilter != nil {
            ToolbarItem(placement: .topBarLeading) {
                Button("نمایش همه", action: showAll)
            }
        }
        if !isEmpty {
            ToolbarItem(placement: .topBarTrailing) {
                LibraryEditButton(editMode: $editMode)
            }
        }
    }

    private func showAll() {
        Haptics.selection()
        withAnimation(.liquid) { router.libraryFilter = nil }
    }
}
