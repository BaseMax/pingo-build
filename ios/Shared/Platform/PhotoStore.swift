import ImageIO
import UIKit

enum PhotoStore {
    static let storedSide: CGFloat = 1000
    private static let quality: CGFloat = 0.85
    private static let thumbnails = NSCache<NSString, UIImage>()
    private static let displays: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 4
        return cache
    }()

    private static var directory: URL {
        AppGroup.container.appendingPathComponent("photos", isDirectory: true)
    }

    static func save(_ data: Data) -> String? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = downsample(source, maxSide: storedSide),
              let jpeg = UIImage(cgImage: image).jpegData(compressionQuality: quality) else { return nil }
        let name = UUID().uuidString + ".jpg"
        return write(jpeg, named: name) ? name : nil
    }

    @discardableResult
    static func write(_ data: Data, named name: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: url(for: name), options: .atomic)
            clearCaches()
            return true
        } catch {
            return false
        }
    }

    static func image(named name: String, maxSide: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url(for: name) as CFURL, nil),
              let image = downsample(source, maxSide: maxSide) else { return nil }
        return UIImage(cgImage: image)
    }

    static func displayImage(named name: String, maxSide: CGFloat) -> UIImage? {
        let key = "\(name)@\(Int(maxSide))" as NSString
        if let cached = displays.object(forKey: key) { return cached }
        guard let image = image(named: name, maxSide: maxSide) else { return nil }
        displays.setObject(image, forKey: key)
        return image
    }

    static func thumbnail(named name: String, side: CGFloat) -> UIImage? {
        let key = "\(name)@\(Int(side))" as NSString
        if let cached = thumbnails.object(forKey: key) { return cached }
        guard let image = image(named: name, maxSide: side) else { return nil }
        thumbnails.setObject(image, forKey: key)
        return image
    }

    static func data(named name: String) -> Data? {
        try? Data(contentsOf: url(for: name))
    }

    static func exists(_ name: String) -> Bool {
        FileManager.default.fileExists(atPath: url(for: name).path)
    }

    static func remove(_ name: String) {
        try? FileManager.default.removeItem(at: url(for: name))
        clearCaches()
    }

    private static func clearCaches() {
        thumbnails.removeAllObjects()
        displays.removeAllObjects()
    }

    private static func url(for name: String) -> URL {
        directory.appendingPathComponent(URL(fileURLWithPath: name).lastPathComponent)
    }

    private static func downsample(_ source: CGImageSource, maxSide: CGFloat) -> CGImage? {
        guard maxSide > 0 else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: min(maxSide, longSide(of: source))
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    private static func longSide(of source: CGImageSource) -> CGFloat {
        let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        let width = properties?[kCGImagePropertyPixelWidth] as? Int ?? Int.max
        let height = properties?[kCGImagePropertyPixelHeight] as? Int ?? Int.max
        return CGFloat(max(width, height))
    }
}
