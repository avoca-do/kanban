import Foundation

extension FileManager {
    #if DEBUG
        static let url = make(url: "avocado.debug.archive")
    #else
        static let url = make(url:"avocado.archive")
    #endif
    
    static var archive: Archive? {
        get {
            try? Data(contentsOf: url).mutating(transform: Archive.init(data:))
        }
        set {
            try? newValue!.data.write(to: url, options: .atomic)
        }
    }
    
    private static func make(url: String) -> URL {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(url)
        var resources = URLResourceValues()
        resources.isExcludedFromBackup = true
        try? url.setResourceValues(resources)
        return url
    }
}
