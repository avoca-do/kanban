import Foundation
import Archivable

public struct Descriptor: Manifest {
    public typealias A = Archive
    
    #if DEBUG
        public static let file = URL.manifest("avocado.debug.archive")
    #else
        public static let file = URL.manifest("avocado.archive")
    #endif
    
    public static let container = "iCloud.avoca.do"
    public static let prefix = "archive_"
}
