import Foundation
import Archivable

extension Array where Element == Board.Column {
    subscript(_ id: Int) -> Path? {
        enumerated().map {
            ($0.0, $0.1.items.enumerated())
        } .reduce(into: [:]) { map, column in
            column.1.forEach {
                map[$0.1.id] = .card(.column(.archive, column.0), $0.0)
            }
        }[id]
    }
    
    func mutating(id: Int, transform: (Board.Card) -> Board.Card) -> Self {
        mutating(id) { path in
            mutating(index: path._column) {
                $0.with(cards: $0.items.mutating(index: path._card, transform: transform))
            }
        }
    }
    
    func moving(id: Int, vertical: Int) -> Self {
        mutating(id) { path in
            mutating(index: path._column) {
                $0.with(cards: $0.items.moving(from: path._card, to: vertical))
            }
        }
    }
    
    func moving(id: Int, horizontal: Int) -> Self {
        mutating(id) { path in
            mutating(index: path._column) {
                $0.with(cards: $0.items.removing(index: path._card))
            }
            .mutating(index: horizontal) {
                $0.with(cards: self[path._column].items[path._card] + $0.items)
            }
        }
    }
    
    func removing(id: Int) -> Self {
        mutating(id) { path in
            mutating(index: path._column) {
                $0.with(cards: $0.items.removing(index: path._card))
            }
        }
    }
    
    private func mutating(_ id: Int, transform: (Path) -> Self) -> Self {
        transform(self[id]!)
    }
}
