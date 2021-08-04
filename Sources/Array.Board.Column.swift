import Foundation
import Archivable

extension Array where Element == Board.Column {
    func mutating(id: Int, transform: (Board.Card) -> Board.Card) -> Self {
        position(for: id) { column, card in
            mutating(index: column) {
                $0.with(cards: $0.items.mutating(index: card, transform: transform))
            }
        }
    }
    
    func moving(id: Int, vertical: Int) -> Self {
        position(for: id) { column, card in
            mutating(index: column) {
                $0.with(cards: $0.items.moving(from: card, to: vertical))
            }
        }
    }
    
    func moving(id: Int, horizontal: Int) -> Self {
        position(for: id) { column, card in
            mutating(index: column) {
                $0.with(cards: $0.items.removing(index: card))
            }
            .mutating(index: horizontal) {
                $0.with(cards: self[column].items[card] + $0.items)
            }
        }
    }
    
    func removing(id: Int) -> Self {
        position(for: id) { column, card in
            mutating(index: column) {
                $0.with(cards: $0.items.removing(index: card))
            }
        }
    }
    
    func position(for id: Int) -> (column: Int, card: Int)? {
        enumerated()
            .flatMap { column in
                column
                    .1
                    .items
                    .enumerated()
                    .map {
                        (id: $0.1.id, column: column.0, card: $0.0)
                    }
            }
            .first {
                $0.0 == id
            }
            .map {
                (column: $0.column, card: $0.card)
            }
    }
    
    private func position(for id: Int, transform: (Int, Int) -> Self) -> Self {
        {
            transform($0.column, $0.card)
        } (position(for: id)!)
    }
}
