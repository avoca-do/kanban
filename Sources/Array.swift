import Foundation

extension Array {
    func mutating(index: Int, transform: (Element) -> Element) -> Self {
        var array = self
        array[index] = transform(array[index])
        return array
    }
    
    func moving(from: Int, to: Int) -> Self {
        var array = self
        array.insert(array.remove(at: from), at: to)
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
        { index in
            mutating(index: index.0) {
                $0.with(cards: $0.cards.mutating(index: index.1, transform: transform))
            }
        } (self[id])
    }
    
    func moving(id: Int, vertical: Int) -> Self {
        { index in
            mutating(index: index.0) {
                $0.with(cards: $0.cards.moving(from: index.1, to: vertical))
            }
        } (self[id])
    }
    
    func moving(id: Int, horizontal: Int) -> Self {
        { index in
            mutating(index: index.0) {
                $0.with(cards: $0.cards.removing(index: index.1))
            }
            .mutating(index: horizontal) {
                $0.with(cards: self[index.0].cards[index.1] + $0.cards)
            }
        } (self[id])
    }
    
    subscript(_ id: Int) -> (Int, Int) {
        enumerated().map {
            ($0.0, $0.1.cards.enumerated())
        } .reduce(into: [:]) { map, column in
            column.1.forEach {
                map[$0.1.id] = (column.0, $0.0)
            }
        }[id]!
    }
}
