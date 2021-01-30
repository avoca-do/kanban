import Foundation

public extension Board {
    struct Column: Hashable {
        public internal(set) var title: String
        
        public var count: Int {
            cards.count
        }
        
        public var isEmpty: Bool {
            cards.isEmpty
        }
        
        var cards: [Card]
        
        init() {
            title = ""
            cards = []
        }
        
        public subscript(_ index: Int) -> String {
            cards[index].content
        }
    }
}
