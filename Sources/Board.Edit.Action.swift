import Foundation

extension Board.Edit {
    enum Action: Equatable, Archivable {
        case
        create,
        card,
        rename(String),
        move(Position, Position),
        content(Position, String)
        
        var data: Data {
            Data()
                .add(key.rawValue)
                .add(content)
        }
        
        init(data: inout Data) {
            switch Key(rawValue: data.removeFirst())! {
            case .create:
                self = .create
            case .card:
                self = .card
            case .rename:
                self = .rename(data.string())
            case .move:
                self = .move(.init(data: &data), .init(data: &data))
            case .content:
                self = .content(.init(data: &data), data.string())
            }
        }
        
        private var content: Data {
            switch self {
            case .create:
                return .init()
            case .card:
                return .init()
            case let .rename(name):
                return Data()
                    .add(name)
            case let .move(from, to):
                return from.data
                    + to.data
            case let .content(position, content):
                return position.data
                    .add(content)
            }
        }
        
        private var key: Key {
            switch self {
            case .create: return .create
            case .card: return .card
            case .rename: return .rename
            case .move: return .move
            case .content: return .content
            }
        }
    }
}

private enum Key: UInt8 {
    case
    create,
    card,
    rename,
    move,
    content
}
