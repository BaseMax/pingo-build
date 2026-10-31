import SwiftUI

enum BackupFeedback: Equatable {
    case exported
    case restored(Int)
    case failed(String)
    case exporting
    case restoring

    var isError: Bool {
        if case .failed = self { return true }
        return false
    }

    var isWorking: Bool {
        self == .exporting || self == .restoring
    }

    var symbol: String {
        isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
    }

    var color: Color {
        if isWorking { return Color.ocean }
        return isError ? Color.red : Color.leaf
    }

    var message: String {
        switch self {
        case .exported: "نسخه پشتیبان ذخیره شد."
        case .restored(let count): "نسخه پشتیبان برگشت و \(Persian.number(count)) مورد جایگزین شد."
        case .failed(let reason): reason
        case .exporting: "دارم نسخه پشتیبان رو آماده می‌کنم. چند لحظه صبر کن."
        case .restoring: "دارم نسخه پشتیبان رو برمی‌گردونم. چند لحظه صبر کن."
        }
    }

    static func from(_ error: Error) -> BackupFeedback {
        if error is BackupError {
            return .failed("این نسخه پشتیبان از یه نسخه جدیدتر پینگو اومده. اول پینگو رو به‌روز کن.")
        }
        if error is DecodingError {
            return .failed("این فایل یه نسخه پشتیبان پینگو نیست.")
        }
        return .failed("یه مشکلی پیش اومد و کار تموم نشد. دوباره امتحان کن.")
    }
}

struct BackupBanner: View {
    let feedback: BackupFeedback

    var body: some View {
        HStack(spacing: 10) {
            indicator
            Text(feedback.message)
                .dasto(14)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(feedback.color)
        .padding(12)
        .background(feedback.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private var indicator: some View {
        if feedback.isWorking {
            ProgressView().tint(feedback.color)
        } else {
            Image(systemName: feedback.symbol)
                .font(.system(size: 16, weight: .semibold))
                .symbolEffect(.bounce, value: feedback)
        }
    }
}
