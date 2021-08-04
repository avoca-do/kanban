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
        case let .column(_, column):
            return column
        case let .card(parent, _):
            return parent.column
        default:
            return 0
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
}
