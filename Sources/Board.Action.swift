import Foundation

extension Board {
    enum Action: Equatable, Archivable {
        case
        create,
        card,
        column,
        rename(String),
        title(Int, String),
        move(Position, Position),
        content(Position, String)
        
        var data: Data {
            Data()
                .add(key.rawValue)
                .add(value)
        }
        
        init(data: inout Data) {
            switch Key(rawValue: data.removeFirst())! {
            case .create:
                self = .create
            case .card:
                self = .card
            case .column:
                self = .column
            case .rename:
                self = .rename(data.string())
            case .title:
                self = .title(.init(data.removeFirst()), data.string())
            case .move:
                self = .move(.init(data: &data), .init(data: &data))
            case .content:
                self = .content(.init(data: &data), data.string())
            }
        }
        
        private var value: Data {
            switch self {
            case .create, .card, .column:
                return .init()
            case let .rename(name):
                return Data()
                    .add(name)
            case let .title(index, title):
                return Data()
                    .add(UInt8(index))
                    .add(title)
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
            case .column: return .column
            case .rename: return .rename
            case .title: return .title
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
    column,
    rename,
    title,
    move,
    content
}
