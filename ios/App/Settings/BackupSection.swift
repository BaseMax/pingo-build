import SwiftUI
import UniformTypeIdentifiers

struct BackupSection: View {
    @State private var document = JSONDocument(data: Data())
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var feedback: BackupFeedback?

    private var isBusy: Bool { feedback?.isWorking == true }

    var body: some View {
        SettingsGroup("نسخه پشتیبان", symbol: "externaldrive.fill") {
            DataSummaryCard()
            controls
        }
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .json,
            defaultFilename: "pingo-backup",
            onCompletion: exported
        )
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Text("یادداشت‌ها، عادت‌ها، فهرست‌ها، شمارنده‌ها و عکس‌های آلبوم‌ها توی یه فایل ذخیره می‌شن.")
                .dasto(14)
                .foregroundStyle(Color.secondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            GlassGroup(spacing: 12) {
                VStack(spacing: 12) {
                    BackupButton("گرفتن نسخه پشتیبان", symbol: "square.and.arrow.up", prominent: true, action: prepareExport)
                    BackupButton("بازیابی از نسخه پشتیبان", symbol: "square.and.arrow.down", prominent: false) {
                        isImporting = true
                    }
                }
            }
            .disabled(isBusy)
            if let feedback {
                BackupBanner(feedback: feedback).transition(.blurFade)
            }
        }
        .panel()
        .animation(.liquid, value: feedback)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], onCompletion: imported)
    }

    private func prepareExport() {
        begin(.exporting)
        Task {
            do {
                document = JSONDocument(data: try await BackupTransfer.exportData())
                withAnimation(.liquid) { feedback = nil }
                isExporting = true
            } catch {
                show(BackupFeedback.from(error))
            }
        }
    }

    private func exported(_ result: Result<URL, Error>) {
        switch result {
        case .success: show(.exported)
        case .failure(let error): report(error)
        }
    }

    private func imported(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url): restore(from: url)
        case .failure(let error): report(error)
        }
    }

    private func restore(from url: URL) {
        begin(.restoring)
        Task {
            do {
                try await BackupTransfer.restore(from: url)
                show(.restored(BackupTransfer.totalItems()))
            } catch {
                show(BackupFeedback.from(error))
            }
        }
    }

    private func report(_ error: Error) {
        guard (error as? CocoaError)?.code != .userCancelled else { return }
        show(BackupFeedback.from(error))
    }

    private func begin(_ value: BackupFeedback) {
        withAnimation(.liquid) { feedback = value }
    }

    private func show(_ value: BackupFeedback) {
        withAnimation(.liquid) { feedback = value }
        if value.isError {
            Haptics.warning()
        } else {
            Haptics.success()
        }
    }
}
