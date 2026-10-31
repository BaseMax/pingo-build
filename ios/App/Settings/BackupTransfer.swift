import Foundation

enum BackupTransfer {
    static func exportData() async throws -> Data {
        try await Task.detached(priority: .userInitiated) {
            try Backup.make { PhotoStore.data(named: $0) }.encoded()
        }.value
    }

    static func restore(from url: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            try restoreSync(from: url)
        }.value
    }

    static func totalItems() -> Int {
        LibraryKind.allCases.reduce(0) { $0 + Store.count(of: $1) }
    }

    private static func restoreSync(from url: URL) throws {
        let scoped = url.startAccessingSecurityScopedResource()
        defer {
            if scoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let backup = try Backup.decoded(from: Data(contentsOf: url))
        backup.restore { name, data in
            _ = PhotoStore.write(data, named: name)
        }
        PhotoSweeper.sweep()
    }
}
