import Foundation

/// Persists quilt thumbnail PNGs under Application Support.
enum ThumbnailStore {
    static func directoryURL() throws -> URL {
        let fm = FileManager.default
        let root = try fm.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = root
            .appendingPathComponent("HabitQuilt", isDirectory: true)
            .appendingPathComponent("thumbnails", isDirectory: true)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Writes PNG bytes for `dayDate` (`YYYY-MM-DD`) and returns the absolute file path.
    @discardableResult
    static func savePNG(dayDate: String, data: Data) throws -> String {
        let url = try directoryURL().appendingPathComponent("\(dayDate).png")
        try data.write(to: url, options: .atomic)
        return url.path
    }

    static func loadPNG(at path: String) -> Data? {
        try? Data(contentsOf: URL(fileURLWithPath: path))
    }
}
