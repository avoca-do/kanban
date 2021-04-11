import Foundation
import Combine
import Archivable

public struct Repository: Repo {
    public static let memory = Memory<Self>()
    
    #if DEBUG
        public static let file = URL.manifest("avocado.debug.archive")
    #else
        public static let file = URL.manifest("avocado.archive")
    #endif
    
    public static let container = "iCloud.avoca.do"
    public static let prefix = "archive_"
    public static internal(set) var override: PassthroughSubject<Archive, Never>?
}
