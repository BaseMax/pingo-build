import SwiftUI

extension ExpiryLevel {
    var color: Color {
        switch self {
        case .healthy: Color.leaf
        case .soon: Color.signal
        case .expired: Color.red
        case .unknown: Color.secondary
        }
    }

    var symbol: String {
        switch self {
        case .healthy: "checkmark.seal.fill"
        case .soon: "clock.badge.exclamationmark.fill"
        case .expired: "exclamationmark.triangle.fill"
        case .unknown: "questionmark.circle.fill"
        }
    }

    var title: String {
        switch self {
        case .healthy: "نصب سالمه"
        case .soon: "داره تموم می‌شه"
        case .expired: "اعتبار تموم شده"
        case .unknown: "اعتبار مشخص نیست"
        }
    }
}
