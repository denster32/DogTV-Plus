import Foundation

// DEPRECATED: Use Cache from DogTVCore instead.
/// A generic, thread-safe in-memory cache for storing `Codable` objects.
/// This cache uses `NSCache` internally to automatically handle memory pressure
/// by evicting objects when system memory is low.
public actor Cache<Key: Hashable, Value: Codable> where Key: Sendable, Value: Sendable {

    private let cache = NSCache<WrappedKey, Entry>()
    private let keyTracker = KeyTracker()

    public init() {}

    /// Inserts a value into the cache for a specified key.
    /// - Parameters:
    ///   - value: The value to store in the cache.
    ///   - key: The key with which to associate the value.
    public func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        let wrappedKey = WrappedKey(key)
        cache.setObject(entry, forKey: wrappedKey)
        keyTracker.keys.insert(key)
    }

    /// Retrieves the value associated with a given key.
    /// - Parameter key: The key for which to retrieve the value.
    /// - Returns: The value associated with the key, or `nil` if the key is not in the cache.
    public func value(forKey key: Key) -> Value? {
        let wrappedKey = WrappedKey(key)
        guard let entry = cache.object(forKey: wrappedKey) else {
            return nil
        }
        return entry.value
    }

    /// Removes the value associated with a given key.
    /// - Parameter key: The key of the value to remove.
    public func removeValue(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        cache.removeObject(forKey: wrappedKey)
        keyTracker.keys.remove(key)
    }

    /// Removes all objects from the cache.
    public func removeAllValues() {
        cache.removeAllObjects()
        keyTracker.keys.removeAll()
    }

    /// Provides an array of all keys currently in the cache.
    public var allKeys: [Key] {
        Array(keyTracker.keys)
    }
}

private extension Cache {
    /// A wrapper class for the key to be used with `NSCache`.
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) {
            self.key = key
            super.init()
        }

        override var hash: Int {
            key.hashValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }

    /// A wrapper class for the value to be stored in `NSCache`.
    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }

    /// A thread-safe key tracker to allow enumeration of keys.
    final class KeyTracker: @unchecked Sendable {
        private let lock = NSLock()
        private var _keys = Set<Key>()

        var keys: Set<Key> {
            get {
                lock.lock()
                defer { lock.unlock() }
                return _keys
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                _keys = newValue
            }
        }
    }
}
