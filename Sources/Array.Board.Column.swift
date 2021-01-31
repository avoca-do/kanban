import Foundation

extension Array where Element == Board.Column {
    func apply(_ action: Board.Action) -> Self {
        var columns = self
        switch action {
        case .create:
            columns = columns.apply(.column)
            columns = columns.apply(.title(0, "DO"))
            columns = columns.apply(.column)
            columns = columns.apply(.title(1, "DOING"))
            columns = columns.apply(.column)
            columns = columns.apply(.title(2, "DONE"))
        case .card:
            columns[0].cards.insert(.init(), at: 0)
        case .column:
            columns.append(.init())
        case let .title(column, title):
            columns[column].title = title
        case let .content(card, text):
            columns[card.column].cards[card.order].content = text
        case let .vertical(card, order):
            columns[card.column].cards.insert(columns[card.column].cards.remove(at: card.order), at: order)
        case let .horizontal(card, column):
            columns[column].cards.insert(columns[card.column].cards.remove(at: card.order), at: 0)
        }
        return columns
    }
}
