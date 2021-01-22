import Foundation

public extension Board {
    struct Card: Hashable {
        public var content = ""
        
        public init(content: String) {
            self.content = content
        }
    }
}
