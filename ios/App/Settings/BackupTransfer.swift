import Foundation

enum BackupTransfer {
    static func exportData() throws -> Data {
        try Backup.make { PhotoStore.data(named: $0) }.encoded()
    }

    static func restore(from url: URL) throws {
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
    }

    static func totalItems() -> Int {
        LibraryKind.allCases.reduce(0) { $0 + Store.count(of: $1) }
    }
}
