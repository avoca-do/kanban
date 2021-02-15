import Foundation

public final class Defaults: UserDefaults {
    public class var capacity: Int {
        get {
            if let capacity = self[.capacity] as? Int {
                NSUbiquitousKeyValueStore.default.set(Int64(capacity), forKey: Key.capacity.rawValue)
                standard.removeObject(forKey: Key.capacity.rawValue)
            }
            return max(.init(NSUbiquitousKeyValueStore.default.longLong(forKey: Key.capacity.rawValue)), 1)
        }
        set {
            NSUbiquitousKeyValueStore.default.set(Int64(newValue), forKey: Key.capacity.rawValue)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }
    
    public class var rated: Bool {
        get { self[.rated] as? Bool ?? false }
        set { self[.rated] = newValue }
    }
    
    public class var created: Date? {
        get { self[.created] as? Date }
        set { self[.created] = newValue }
    }
    
    public class var spell: Bool {
        get { self[.spell] as? Bool ?? true }
        set { self[.spell] = newValue }
    }
    
    public class var correction: Bool {
        get { self[.correction] as? Bool ?? false }
        set { self[.correction] = newValue }
    }
    
    private class subscript(_ key: Key) -> Any? {
        get { standard.object(forKey: key.rawValue) }
        set { standard.setValue(newValue, forKey: key.rawValue) }
    }
}
