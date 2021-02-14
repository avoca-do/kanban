import Foundation

extension Array where Element == Board.Column {
    subscript(_ id: Int) -> Path? {
        enumerated().map {
            ($0.0, $0.1.cards.enumerated())
        } .reduce(into: [:]) { map, column in
            column.1.forEach {
                map[$0.1.id] = .card(.column(.archive, column.0), $0.0)
            }
        }[id]
    }
    
    func mutating(id: Int, transform: (Board.Card) -> Board.Card) -> Self {
        mutating(id) { path in
            mutating(index: path.column) {
                $0.with(cards: $0.cards.mutating(index: path.card, transform: transform))
            }
        }
    }
    
    func moving(id: Int, vertical: Int) -> Self {
        mutating(id) { path in
            mutating(index: path.column) {
                $0.with(cards: $0.cards.moving(from: path.card, to: vertical))
            }
        }
    }
    
    func moving(id: Int, horizontal: Int) -> Self {
        mutating(id) { path in
            mutating(index: path.column) {
                $0.with(cards: $0.cards.removing(index: path.card))
            }
            .mutating(index: horizontal) {
                $0.with(cards: self[path.column].cards[path.card] + $0.cards)
            }
        }
    }
    
    func removing(id: Int) -> Self {
        mutating(id) { path in
            mutating(index: path.column) {
                $0.with(cards: $0.cards.removing(index: path.card))
            }
        }
    }
    
    private func mutating(_ id: Int, transform: (Path) -> Self) -> Self {
        transform(self[id]!)
    }
}
