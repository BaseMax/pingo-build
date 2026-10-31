import PhotosUI
import SwiftUI

struct AlbumEditorView: View {
    private let id: String
    @State private var draft: AlbumItem
    @State private var picked: [PhotosPickerItem] = []
    @State private var importing = false
    @State private var confetti = 0

    init(id: String) {
        self.id = id
        _draft = State(initialValue: Store.albums.item(id) ?? AlbumItem(id: id))
    }

    private var tint: Color {
        Theme.resolved(draft.theme, for: .photo).panelTint
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ItemPreviewHeader(kind: .photo, id: id).editorStage(0)
                LiquidTextField("اسم آلبوم", text: $draft.title, symbol: "photo.on.rectangle.angled").editorStage(1)
                photos.editorStage(2)
                options.editorStage(3)
            }
            .padding(.horizontal, Layout.gutter)
            .padding(.top, 8)
        }
        .overlay(alignment: .bottom) {
            ConfettiBurst(trigger: confetti).ignoresSafeArea()
        }
        .liquidScreen()
        .navigationTitle(draft.title.isEmpty ? "آلبوم" : draft.title)
        .navigationBarTitleDisplayMode(.inline)
        .syncsDraft($draft, with: Store.albums)
        .deletesItem(message: "عکس‌های این آلبوم هم از گوشی پاک می‌شن.", perform: deleteAlbum)
        .onChange(of: picked) { _, items in
            importPicked(items)
        }
    }

    private var photos: some View {
        VStack(spacing: 12) {
            SectionTitle("عکس‌ها، \(Persian.number(draft.photos.count))", symbol: "photo")
            addButton
            if draft.photos.isEmpty {
                EmptyState(
                    symbol: "photo.on.rectangle.angled",
                    title: "هنوز عکسی نیست",
                    message: "چندتا عکس اضافه کن تا قاب جون بگیره."
                )
                .padding(.vertical, 24)
                .panel()
                .transition(.blurFade)
            } else {
                AlbumPhotoGrid(photos: draft.photos, onRemove: remove, onMove: move)
                    .transition(.blurFade)
            }
        }
        .animation(.liquid, value: draft.photos.isEmpty)
    }

    private var addButton: some View {
        PhotosPicker(selection: $picked, maxSelectionCount: 12, matching: .images) {
            HStack(spacing: 8) {
                if importing {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "photo.badge.plus")
                }
                Text("افزودن عکس")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(LiquidButtonStyle(prominent: true, tint: tint))
        .disabled(importing)
    }

    private var options: some View {
        VStack(spacing: 10) {
            SectionTitle("نمایش", symbol: "slider.horizontal.3")
            AlbumIntervalRow(minutes: $draft.minutes)
            LiquidToggleRow("نمایش عنوان روی عکس", symbol: "textformat", isOn: $draft.showsTitle)
            ThemePickerRow(selection: $draft.theme)
        }
    }

    private func importPicked(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        picked = []
        importing = true
        Task {
            let names = await AlbumImporter.importPhotos(items)
            await append(names)
            importing = false
        }
    }

    private func append(_ names: [String]) async {
        guard Store.albums.item(id) != nil else {
            names.forEach { PhotoStore.remove($0) }
            return
        }
        for name in names {
            withAnimation(.liquid) {
                draft.photos.append(name)
            }
            Haptics.soft()
            try? await Task.sleep(for: .milliseconds(90))
        }
        if !names.isEmpty {
            confetti += 1
            Haptics.success()
        }
    }

    private func remove(_ name: String) {
        Haptics.warning()
        withAnimation(.liquid) {
            draft.photos.removeAll { $0 == name }
        }
        PhotoStore.remove(name)
    }

    private func move(_ source: String, to target: String) {
        guard let from = draft.photos.firstIndex(of: source),
              let to = draft.photos.firstIndex(of: target),
              from != to else { return }
        withAnimation(.liquid) {
            draft.photos.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
        }
        Haptics.selection()
    }

    private func deleteAlbum() {
        (Store.albums.item(id) ?? draft).cleanUp()
        Store.albums.remove(id)
    }
}
