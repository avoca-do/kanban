import Foundation

public extension Board {
    struct Column: Hashable {
        public var name: String
        public var cards = [Card]()
        
        public init(name: String) {
            self.name = name
        }
    }
}
