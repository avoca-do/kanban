import Foundation
import Archivable

extension Board {
    public struct Column: Pather, PatherItem {
        let title: String

        public let items: [Card]
        
        public init() {
            title = ""
            items = []
        }
        
        private init(title: String, cards: [Card]) {
            self.title = title
            self.items = cards
        }
        
        func adding(id: Int) -> Self {
            with(cards: .init(id: id) + items)
        }
        
        func with(cards: [Card]) -> Self {
            .init(title: title, cards: cards)
        }
        
        func with(title: String) -> Self {
            .init(title: title, cards: items)
        }
    }
}
