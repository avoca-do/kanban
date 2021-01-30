import Foundation

extension Board {
    enum Action: Equatable, Archivable {
        case
        create,
        card,
        column,
        rename(String),
        title(Int, String),
        content(Index, String),
        vertical(Index, Int),
        horizontal(Index, Int)
        
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
            case .vertical:
                self = .vertical(.init(data: &data), .init(data.uInt16()))
            case .horizontal:
                self = .horizontal(.init(data: &data), .init(data.removeFirst()))
            }
        }
        
        private var value: Data {
            switch self {
            case .create, .card, .column:
                return .init()
            case let .rename(name):
                return Data()
                    .add(name)
            case let .title(column, title):
                return Data()
                    .add(UInt8(column))
                    .add(title)
            case let .content(card, content):
                return card.data
                    .add(content)
            case let .vertical(card, order):
                return card.data
                    .add(UInt16(order))
            case let .horizontal(card, column):
                return card.data
                    .add(UInt8(column))
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
            case .vertical: return .vertical
            case .horizontal: return .horizontal
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
    vertical,
    horizontal
}
