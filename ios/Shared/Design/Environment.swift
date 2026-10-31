import SwiftUI

private struct AnimatesKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var animates: Bool {
        get { self[AnimatesKey.self] }
        set { self[AnimatesKey.self] = newValue }
    }
}
