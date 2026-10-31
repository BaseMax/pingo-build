import Foundation

extension PhotoStore {
    static func copy(_ name: String) -> String? {
        guard let data = data(named: name) else { return nil }
        let copyName = UUID().uuidString + ".jpg"
        return write(data, named: copyName) ? copyName : nil
    }
}
