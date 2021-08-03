import Foundation
import Archivable

extension Board {
    public struct Column: Pather, PatherItem {
        public let name: String
        public let items: [Card]
        
        public init() {
            name = ""
            items = []
        }
        
        private init(name: String, cards: [Card]) {
            self.name = name
            self.items = cards
        }
        
        func adding(id: Int) -> Self {
            with(cards: .init(id: id) + items)
        }
        
        func with(cards: [Card]) -> Self {
            .init(name: name, cards: cards)
        }
        
        func with(name: String) -> Self {
            .init(name: name, cards: items)
        }
    }
}
