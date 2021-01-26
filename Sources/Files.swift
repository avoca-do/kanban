import Foundation

extension FileManager {
    static var archive: Archive? {
        get {
            (try? Data(contentsOf: _archive))?.mutating {
                .init(data: &$0)
            }
        }
        set {
            try? newValue!.data.write(to: _archive, options: .atomic)
        }
    }
    
    private static let _root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    #if DEBUG
        private static let _archive = _root.appendingPathComponent("archive")
    #else
        private static let _archive = _root.appendingPathComponent("debug")
    #endif
}
