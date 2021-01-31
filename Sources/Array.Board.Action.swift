import Foundation

extension Array where Element == Board.Action {
    func compress(from state: [Board.Column], to columns: [Board.Column]) -> Self {
        var state = state
        var columns = columns
        var map = [UUID : [Board.Key]]()
        return self.reversed().reduce(into: []) {
            switch $1 {
            case let .content(card, _):
                let id = columns[card.column].cards[card.order].id
                if map[id]?.contains(.content) != true {
                    $0.append($1)
                    map[id] = map[id].map { $0 + [.content] } ?? [.content]
                } 
            default:
                $0.append($1)
            }
            
        }.reversed()
    }
}
