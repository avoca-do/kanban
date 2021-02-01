import Foundation

public extension Board {
    struct Column: Equatable {
        public let title: String
        
        public var count: Int {
            cards.count
        }
        
        public var isEmpty: Bool {
            cards.isEmpty
        }
        
        let cards: [Card]
        
        init() {
            title = ""
            cards = []
        }
        
        private init(title: String, cards: [Card]) {
            self.title = title
            self.cards = cards
        }
        
        func adding(id: Int) -> Self {
            .init(title: title, cards: .init(id: id) + cards)
        }
        
        subscript(_ index: Int) -> Int {
            cards[index].id
        }
        
        subscript(_ index: Int) -> String {
            cards[index].content
        }
    }
}
