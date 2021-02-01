import Foundation

extension Array {
    func mutating(index: Int, transform: (Element) -> Element) -> Self {
        var array = self
        array[index] = transform(array[index])
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
        } (map[id]!)
    }
    
    private var map: [Int : (Int, Int)] {
        enumerated().map {
            ($0.0, $0.1.cards.enumerated())
        } .reduce(into: [:]) { map, column in
            column.1.forEach {
                map[$0.1.id] = (column.0, $0.0)
            }
        }
    }
}
