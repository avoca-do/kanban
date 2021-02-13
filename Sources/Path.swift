import Foundation

public indirect enum Path: Equatable {
    case
    empty,
    board(Int),
    column(Self, Int),
    card(Self, Int)
    
    public var up: Self {
        switch self {
        case .board: return .empty
        case let .column(board, _): return board
        case let .card(column, _): return column
        default: return self
        }
    }
    
    public func down(_ index: Int) -> Self {
        switch self {
        case .empty: return .board(index)
        case .board: return .column(self, index)
        case .column: return .card(self, index)
        default: return self
        }
    }
}
