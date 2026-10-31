import Foundation

enum PhotoSweeper {
    static func sweep() {
        let kept = Set(Store.albums.all.flatMap(\.photos))
        let names = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        names.filter { !kept.contains($0) }.forEach { PhotoStore.remove($0) }
    }

    private static var directory: URL {
        AppGroup.container.appendingPathComponent("photos", isDirectory: true)
    }
}
