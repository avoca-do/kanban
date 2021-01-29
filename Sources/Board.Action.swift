import Foundation

extension Board {
    enum Action: Equatable, Archivable {
        case
        create,
        card,
        column,
        rename(String),
        title(Int, String),
        content(Position, String),
        order(Position, Int)
        
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
            case .content:
                self = .content(.init(data: &data), data.string())
            case .order:
                self = .order(.init(data: &data), .init(data.uInt16()))
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
            case let .content(position, content):
                return position.data
                    .add(content)
            case let .order(card, index):
                return card.data
                    .add(UInt16(index))
            }
        }
        
        private var key: Key {
            switch self {
            case .create: return .create
            case .card: return .card
            case .column: return .column
            case .rename: return .rename
            case .title: return .title
            case .content: return .content
            case .order: return .order
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
    content,
    order
}
