import Foundation

public final class Defaults: UserDefaults {
    public class var archive: Archive? {
        get {
            cross.data(forKey: Key.archive.rawValue)?.mutating(transform: Archive.init(data:))
        }
        set {
            newValue.map {
                cross.setValue($0.data, forKey: Key.archive.rawValue)
            }
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
    
    private static let cross = UserDefaults(suiteName: "group.avoca.do.Cross")!
    
    private class subscript(_ key: Key) -> Any? {
        get { standard.object(forKey: key.rawValue) }
        set { standard.setValue(newValue, forKey: key.rawValue) }
    }
}
