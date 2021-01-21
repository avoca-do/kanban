import Foundation

public extension Board {
    struct Card: Codable, Identifiable, Hashable {
        public var content = ""
        public let id: String
        
        public init(content: String) {
            self.content = content
            id = UUID().uuidString
        }
    }
}
