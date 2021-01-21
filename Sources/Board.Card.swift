import Foundation

public extension Board {
    struct Card: Codable, Hashable {
        public var content = ""
        
        public init(content: String) {
            self.content = content
        }
    }
}
