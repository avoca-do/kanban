import Foundation

public indirect enum Path: Equatable {
    case
    archive,
    board(Int),
    column(Self, Int),
    card(Self, Int)
    
    public var board: Self {
        switch self {
        case .board: return self
        case let .column(parent, _), let .card(parent, _): return parent.board
        default: return .archive
        }
    }
    
    public var column: Self {
        switch self {
        case .column: return self
        case let .card(parent, _): return parent.column
        default: return .archive
        }
    }
    
    public var card: Self {
        switch self {
        case .card: return self
        default: return .archive
        }
    }
    
    var _board: Int {
        switch self {
        case let .board(board): return board
        case let .column(parent, _), let .card(parent, _): return parent._board
        default: return 0
        }
    }
    
    var _column: Int {
        switch self {
        case let .column(_, column): return column
        case let .card(parent, _): return parent._column
        default: return 0
        }
    }
    
    var _card: Int {
        switch self {
        case let .card(_, card): return card
        default: return 0
        }
    }
}
