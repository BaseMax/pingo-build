import XCTest

enum Shots {
    static var directory: URL {
        let path = ProcessInfo.processInfo.environment["SMOKE_DIR"] ?? "/tmp/pingo-smoke"
        return URL(fileURLWithPath: path, isDirectory: true)
    }

    private static var missingFile: URL {
        directory.appendingPathComponent("missing-elements.txt")
    }

    static func prepare() {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private static func nextName(_ slug: String) -> String {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        let count = files.filter { $0.hasSuffix(".png") }.count
        return String(format: "%03d-%@", count + 1, slug)
    }

    static func save(_ slug: String, in test: XCTestCase) {
        let name = nextName(slug)
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        test.add(attachment)
        try? shot.pngRepresentation.write(to: directory.appendingPathComponent(name + ".png"))
    }

    static func recordMissing(_ line: String) {
        let data = Data((line + "\n").utf8)
        if let handle = try? FileHandle(forWritingTo: missingFile) {
            handle.seekToEndOfFile()
            handle.write(data)
            try? handle.close()
        } else {
            try? data.write(to: missingFile)
        }
    }
}
