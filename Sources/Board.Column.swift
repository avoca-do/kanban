import Foundation

public extension Board {
    struct Column: Hashable {
        public internal(set) var title: String
        
        public var count: Int {
            cards.count
        }
        
        private var cards: [String]
        
        init() {
            title = ""
            cards = []
        }
        
        public subscript(_ index: Int) -> String {
            cards[index]
        }
    }
}
