import Foundation

// DEPRECATED: Use FileStorage from DogTVCore instead.
/// A utility for storing and retrieving Codable objects from the file system.
public actor FileStorage {

    private let fileManager: FileManager
    private let directory: URL

    /// Initializes the file storage utility.
    /// - Parameter directoryName: The name of the directory to store files in.
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

    /// Saves a Codable object to a file.
    /// - Parameters:
    ///   - object: The object to save.
    ///   - fileName: The name of the file to save to.
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

    /// Loads a Codable object from a file.
    /// - Parameter fileName: The name of the file to load from.
    /// - Returns: The loaded object, or `nil` if the file doesn't exist or decoding fails.
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

    /// Backs up a file to a new location.
    /// - Parameter fileName: The name of the file to back up.
    /// - Returns: The URL of the backup file, or `nil` on failure.
    public func backup(file fileName: String) -> URL? {
        let sourceURL = directory.appendingPathComponent(fileName)
        let backupFileName = "\(fileName).backup"
        let backupURL = directory.appendingPathComponent(backupFileName)

        do {
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            try fileManager.copyItem(at: sourceURL, to: backupURL)
            return backupURL
        } catch {
            print("Backup failed: \(error.localizedDescription)")
            return nil
        }
    }
}
