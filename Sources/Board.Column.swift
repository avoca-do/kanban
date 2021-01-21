import Foundation

public extension Board {
    struct Column: Codable, Hashable {
        public var name: String
        public var cards = [Card]()
        
        public func hash(into: inout Hasher) {
            into.combine(name)
            into.combine(cards)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name && lhs.cards == rhs.cards
        }
    }
}
