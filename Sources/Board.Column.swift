import Foundation
import Archivable

extension Board {
    struct Column: Equatable {
        let title: String
        
        var count: Int {
            cards.count
        }
        
        var isEmpty: Bool {
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
        
        subscript(_ path: Path) -> Card {
            path._card >= 0 && path._card < count ? cards[path._card] : .init(id: 0)
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
    }
}
