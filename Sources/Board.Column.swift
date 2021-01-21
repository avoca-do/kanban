import Foundation

public extension Board {
    struct Column: Codable, Identifiable, Hashable {
        public var name: String
        public var cards = [Card]()
        public let id: String
        
        public init(name: String) {
            self.name = name
            id = UUID().uuidString
        }
    }
}
