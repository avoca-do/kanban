import Foundation

extension Array {
    func mutating(index: Int, transform: (Element) -> Element) -> Self {
        var array = self
        array[index] = transform(array[index])
        return array
    }
    
    func moving(from: Int, to: Int) -> Self {
        var array = self
        array.insert(array.remove(at: from), at: Swift.min(to, array.count))
        return array
    }
    
    func removing(index: Int) -> Self {
        var array = self
        array.remove(at: index)
        return array
    }
    
    static func +(array: Self, element: Element) -> Self {
        var array = array
        array.append(element)
        return array
    }
    
    static func +(element: Element, array: Self) -> Self {
        var array = array
        array.insert(element, at: 0)
        return array
    }
}

extension Array where Element == Board.Column {
    func mutating(id: Int, transform: (Board.Card) -> Board.Card) -> Self {
        { position in
            mutating(index: position.column) {
                $0.with(cards: $0.cards.mutating(index: position.index, transform: transform))
            }
        } (self[id]!)
    }
    
    func moving(id: Int, vertical: Int) -> Self {
        { position in
            mutating(index: position.column) {
                $0.with(cards: $0.cards.moving(from: position.index, to: vertical))
            }
        } (self[id]!)
    }
    
    func moving(id: Int, horizontal: Int) -> Self {
        { position in
            mutating(index: position.column) {
                $0.with(cards: $0.cards.removing(index: position.index))
            }
            .mutating(index: horizontal) {
                $0.with(cards: self[position.column].cards[position.index] + $0.cards)
            }
        } (self[id]!)
    }
    
    subscript(_ id: Int) -> Board.Position? {
        enumerated().map {
            ($0.0, $0.1.cards.enumerated())
        } .reduce(into: [:]) { map, column in
            column.1.forEach {
                map[$0.1.id] = .init(column: column.0, index: $0.0)
            }
        }[id]
    }
}
