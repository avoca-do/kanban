import Foundation

extension Board {
    enum Action: Equatable, Archivable {
        case
        create,
        card,
        column,
        title(Int, String),
        content(Int, String),
        vertical(Int, Int),
        horizontal(Int, Int)
        
        var data: Data {
            Data()
                .adding(key.rawValue)
                .adding(value)
        }
        
        init(data: inout Data) {
            switch Key(rawValue: data.removeFirst())! {
            case .create:
                self = .create
            case .card:
                self = .card
            case .column:
                self = .column
            case .title:
                self = .title(.init(data.removeFirst()), data.string())
            case .content:
                self = .content(.init(data.uInt16()), data.string())
            case .vertical:
                self = .vertical(.init(data.uInt16()), .init(data.uInt16()))
            case .horizontal:
                self = .horizontal(.init(data.uInt16()), .init(data.removeFirst()))
            }
        }
        
        func overrides(_ action: Self) -> Bool {
            switch self {
            case let .content(id, _):
                if case let .content(other, _) = action, id == other {
                    return true
                }
            case let .horizontal(id, _):
                if case let .horizontal(other, _) = action, id == other {
                    return true
                }
            case let .vertical(id, _):
                if case let .vertical(other, _) = action, id == other {
                    return true
                }
            default: break
            }
            return false
        }
        
        private var value: Data {
            switch self {
            case .create, .card, .column:
                return .init()
            case let .title(column, title):
                return Data()
                    .adding(UInt8(column))
                    .adding(title)
            case let .content(id, content):
                return Data()
                        .adding(UInt16(id))
                        .adding(content)
            case let .vertical(id, index):
                return Data()
                        .adding(UInt16(id))
                        .adding(UInt16(index))
            case let .horizontal(id, column):
                return Data()
                        .adding(UInt16(id))
                        .adding(UInt8(column))
            }
        }
        
        var key: Key {
            switch self {
            case .create: return .create
            case .card: return .card
            case .column: return .column
            case .title: return .title
            case .content: return .content
            case .vertical: return .vertical
            case .horizontal: return .horizontal
            }
        }
    }
}
