import SwiftUI

@main
struct PingoApp: App {
    @State private var router = AppRouter()

    init() {
        Store.prepare()
    }

    var body: some Scene {
        WindowGroup {
            AppContent(router: router)
        }
    }
}
