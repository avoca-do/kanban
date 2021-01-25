import Foundation

extension Board.Edit {
    enum Action: Equatable {
        case
        create,
        card,
        rename(String),
        move(Position, Position),
        content(Position, String)
        
        var value: UInt8 {
            switch self {
            case .create: return 0
            case .card: return 1
            case .rename: return 2
            case .move: return 3
            case .content: return 4
            }
        }
    }
}
