import Foundation

public extension Board {
    struct Column: Placeholderable, Equatable {
        static let placeholder = Self()
        
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
            with(cards: .init(id: id) + cards)
        }
        
        func with(cards: [Card]) -> Self {
            .init(title: title, cards: cards)
        }
        
        func with(title: String) -> Self {
            .init(title: title, cards: cards)
        }
        
        subscript(_ index: Int) -> Int {
            cards[index].id
        }
        
        subscript(_ index: Int) -> String {
            index < count ? cards[index].content : ""
        }
    }
}
