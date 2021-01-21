import Foundation

public extension Board {
    struct Column: Codable {
        public var name: String
        public var cards = [Card]()
    }
}
