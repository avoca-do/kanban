import Foundation
import Combine

extension FileManager {
    static var archive: Data? {
        get {
            try? .init(contentsOf: _archive)
        }
        set {
            try? newValue!.write(to: _archive, options: .atomic)
        }
    }
    
    private static let _root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    #if DEBUG
        private static let _archive = _root.appendingPathComponent("archive")
    #else
        private static let _archive = _root.appendingPathComponent("debug")
    #endif
}
