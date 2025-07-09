import Foundation

/// A generic, thread-safe in-memory cache for storing `Codable` objects.
/// This cache uses `NSCache` internally to automatically handle memory pressure
/// by evicting objects when system memory is low.
public actor Cache<Key: Hashable, Value: Codable> where Key: Sendable, Value: Sendable {
    private let cache = NSCache<WrappedKey, Entry>()
    private let keyTracker = KeyTracker()
    public init() {}
    public func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        let wrappedKey = WrappedKey(key)
        cache.setObject(entry, forKey: wrappedKey)
        keyTracker.keys.insert(key)
    }
    public func value(forKey key: Key) -> Value? {
        let wrappedKey = WrappedKey(key)
        guard let entry = cache.object(forKey: wrappedKey) else { return nil }
        return entry.value
    }
    public func removeValue(forKey key: Key) {
        let wrappedKey = WrappedKey(key)
        cache.removeObject(forKey: wrappedKey)
        keyTracker.keys.remove(key)
    }
    private final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) { self.key = key }
        override var hash: Int { key.hashValue }
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }
            return value.key == key
        }
    }
    private final class Entry: NSObject {
        let value: Value
        init(value: Value) { self.value = value }
    }
    private final class KeyTracker {
        var keys = Set<Key>()
    }
}
