import Foundation

public indirect enum Path: Equatable {
    case
    archive,
    board(Int),
    column(Self, Int),
    card(Self, Int)
    
    public var up: Self {
        switch self {
        case .board: return .archive
        case let .column(board, _): return board
        case let .card(column, _): return column
        default: return self
        }
    }
    
    public func down(_ index: Int) -> Self {
        switch self {
        case .archive: return .board(index)
        case .board: return .column(self, index)
        case .column: return .card(self, index)
        default: return self
        }
    }
    
    var board: Int {
        switch self {
        case let .board(board): return board
        case let .column(parent, _), let .card(parent, _): return parent.board
        default: return 0
        }
    }
    
    var column: Int {
        switch self {
        case let .column(_, column): return column
        case let .card(parent, _): return parent.column
        default: return 0
        }
    }
    
    var card: Int {
        switch self {
        case let .card(_, card): return card
        default: return 0
        }
    }
}
