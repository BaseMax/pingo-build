import SwiftUI

struct GalleryView: View {
    @Environment(AppRouter.self) private var router
    @State private var query = ""
    @Namespace private var zoom

    var body: some View {
        NavigationStack(path: Bindable(router).galleryPath) {
            GalleryContent(query: query, namespace: zoom)
                .navigationTitle("ویجت‌ها")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $query, prompt: "جستجوی ویجت")
                .toolbar { guideButton }
                .navigationDestination(for: PingoKind.self) { kind in
                    KindDetailView(kind: kind)
                        .navigationTransition(.zoom(sourceID: kind, in: zoom))
                }
                .navigationDestination(for: ItemRoute.self) { route in
                    ItemEditorView(route: route)
                }
        }
    }

    @ToolbarContentBuilder
    private var guideButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ToolbarIconButton(symbol: "questionmark") {
                router.open(.guide(nil))
            }
            .accessibilityLabel("راهنما")
        }
    }
}

private struct GalleryContent: View {
    let query: String
    let namespace: Namespace.ID

    private var sections: [GalleryGroup] {
        PingoCategory.allCases.compactMap { category -> GalleryGroup? in
            let kinds = PingoKind.allCases.filter { $0.category == category && matches($0) }
            return kinds.isEmpty ? nil : GalleryGroup(category: category, kinds: kinds)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                subtitle
                if sections.isEmpty {
                    emptyResult
                } else {
                    ForEach(sections) { group in
                        GallerySection(group: group, namespace: namespace)
                    }
                }
            }
            .padding(.horizontal, Layout.gutter)
            .padding(.top, 4)
            .animation(.liquid, value: query)
        }
        .liquidScreen()
    }

    private var subtitle: some View {
        Text("یکی رو انتخاب کن و بذارش روی صفحه اصلیت.")
            .dasto(14)
            .foregroundStyle(Color.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .reveal()
    }

    private var emptyResult: some View {
        EmptyState(
            symbol: "magnifyingglass",
            title: "چیزی پیدا نشد",
            message: "یه اسم دیگه رو امتحان کن، مثلا ساعت یا ماه."
        )
        .padding(.top, 48)
    }

    private func matches(_ kind: PingoKind) -> Bool {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return true }
        return kind.title.localizedCaseInsensitiveContains(text)
            || kind.about.localizedCaseInsensitiveContains(text)
    }
}

private struct GalleryGroup: Identifiable {
    let category: PingoCategory
    let kinds: [PingoKind]

    var id: PingoCategory { category }
    var compact: [PingoKind] { kinds.filter { !$0.galleryIsWide } }
    var wide: [PingoKind] { kinds.filter { $0.galleryIsWide } }
}

private struct GallerySection: View {
    let group: GalleryGroup
    let namespace: Namespace.ID

    private let columns = [
        GridItem(.flexible(), spacing: 14, alignment: .top),
        GridItem(.flexible(), spacing: 14, alignment: .top)
    ]

    var body: some View {
        VStack(spacing: 14) {
            SectionTitle(group.category.title, symbol: group.category.symbol)
            LazyVGrid(columns: columns, spacing: 22) {
                ForEach(Array(group.compact.enumerated()), id: \.element) { index, kind in
                    card(kind, index: index)
                }
            }
            ForEach(Array(group.wide.enumerated()), id: \.element) { index, kind in
                card(kind, index: index)
            }
        }
    }

    private func card(_ kind: PingoKind, index: Int) -> some View {
        KindCard(kind: kind, namespace: namespace)
            .scrollBlur()
            .reveal(Double(min(index, 5)) * 0.07)
    }
}
