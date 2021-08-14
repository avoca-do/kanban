import Foundation

public indirect enum Path: Identifiable, Hashable {
    public var id: String {
        "\(self)"
    }
    
    case
    board(Int),
    column(Self, Int),
    card(Self, Int)
    
    public var board: Int {
        switch self {
        case let .board(board):
            return board
        case let .column(parent, _), let .card(parent, _):
            return parent.board
        }
    }
    
    public var column: Int {
        switch self {
        case .board:
            return 0
        case let .column(_, column):
            return column
        case let .card(parent, _):
            return parent.column
        }
    }
    
    public var card: Int {
        switch self {
        case let .card(_, card):
            return card
        default:
            return 0
        }
    }
    
    func child(index: Int) -> Self {
        switch self {
        case .board:
            return .column(self, index)
        case .column:
            return .card(self, index)
        case .card:
            return self
        }
    }
}
