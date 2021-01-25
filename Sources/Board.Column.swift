import Foundation

public extension Board {
    struct Column: Hashable {
        public internal(set) var title: String
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
