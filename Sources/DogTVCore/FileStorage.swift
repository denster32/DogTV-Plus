import Foundation

/// A utility for storing and retrieving Codable objects from the file system.
public actor FileStorage {
    private let fileManager: FileManager
    private let directory: URL

    public init(directoryName: String) {
        self.fileManager = FileManager.default
        if let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.directory = url.appendingPathComponent(directoryName)
            if !fileManager.fileExists(atPath: directory.path) {
                do {
                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating directory: \(error.localizedDescription)")
                }
            }
        } else {
            fatalError("Could not find document directory.")
        }
    }

    public func save<T: Codable>(_ object: T, to fileName: String, compressed: Bool = false) throws {
        let url = directory.appendingPathComponent(fileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var data = try encoder.encode(object)
        if compressed {
            data = try (data as NSData).compressed(using: .zlib) as Data
        }
        try data.write(to: url)
    }

    public func load<T: Codable>(from fileName: String, compressed: Bool = false) throws -> T? {
        let url = directory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        var data = try Data(contentsOf: url)
        if compressed {
            data = try (data as NSData).decompressed(using: .zlib) as Data
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    public func backup(file fileName: String) -> Bool {
        let url = directory.appendingPathComponent(fileName)
        let backupURL = directory.appendingPathComponent(fileName + ".bak")
        do {
            if fileManager.fileExists(atPath: url.path) {
                if fileManager.fileExists(atPath: backupURL.path) {
                    try fileManager.removeItem(at: backupURL)
                }
                try fileManager.copyItem(at: url, to: backupURL)
                return true
            }
        } catch {
            print("Backup failed: \(error.localizedDescription)")
        }
        return false
    }
}
