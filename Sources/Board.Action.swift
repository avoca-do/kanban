import Foundation
import Archivable

extension Board {
    enum Action: Property, Equatable {
        case
        create,
        card,
        column,
        name(Int, String),
        content(Int, String),
        vertical(Int, Int),
        horizontal(Int, Int),
        remove(Int),
        drop(Int)
        
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
            case .name:
                self = .name(.init(data.removeFirst()), data.string())
            case .content:
                self = .content(.init(data.uInt16()), data.string())
            case .vertical:
                self = .vertical(.init(data.uInt16()), .init(data.uInt16()))
            case .horizontal:
                self = .horizontal(.init(data.uInt16()), .init(data.removeFirst()))
            case .remove:
                self = .remove(.init(data.uInt16()))
            case .drop:
                self = .drop(.init(data.removeFirst()))
            }
        }
        
        func allows(_ action: Self, on: Snap) -> Bool {
            switch self {
            case let .content(id, _):
                if case let .content(other, _) = action, id == other {
                    return false
                }
            case let .horizontal(id, _):
                switch action {
                case let .horizontal(other, _), let .vertical(other, _):
                    return id != other
                default:
                    break
                }
            case let .vertical(id, _):
                if case let .vertical(other, _) = action, id == other {
                    return false
                }
            case let .name(column, _):
                if case let .name(other, _) = action, column == other {
                    return false
                }
            case let .remove(id):
                switch action {
                case let .content(other, _), let .horizontal(other, _), let .vertical(other, _):
                    return id != other
                default:
                    break
                }
            case let .drop(column):
                switch action {
                case let .name(other, _):
                    return column != other
                case let .content(id, _), let .vertical(id, _):
                    return column != on.items.position(for: id)!.column
                default:
                    break
                }
            default:
                break
            }
            return true
        }
        
        func redundant(_ from: Snap?, _ to: Snap) -> Bool {
            switch self {
            case let .content(id, content):
                return from
                    .flatMap { snap in
                        snap
                            .items
                            .position(for: id)
                            .map {
                                snap[$0.column][$0.card].content == content
                            }
                    }
                    ?? to
                    .items
                    .position(for: id)
                    .map {
                        to[$0.column][$0.card].content == content
                    }
                    ?? false
            case let .horizontal(id, column):
                if let previous = from?.items.position(for: id)?.column {
                    return previous == column
                } else {
                    if column == 0 && to.counter == id + 1 {
                        return true
                    }
                }
            case let .vertical(id, card):
                let next = to.items.position(for: id)!
                if next.card == card {
                    return true
                } else if let previous = from?.items.position(for: id) {
                    return previous.column == next.column && previous.card == card
                } else if next.column == 0 && card == 0 && to.counter == id + 1 {
                    return true
                }
            case let .name(column, name):
                if to[column].name == name {
                    return true
                } else if let from = from,
                   from.count > column,
                   from[column].name == name {
                    return true
                }
            default:
                break
            }
            return false
        }
        
        private var value: Data {
            switch self {
            case .create, .card, .column:
                return .init()
            case let .name(column, title):
                return Data()
                    .adding(UInt8(column))
                    .adding(title)
            case let .content(id, content):
                return Data()
                        .adding(UInt16(id))
                        .adding(content)
            case let .vertical(id, card):
                return Data()
                        .adding(UInt16(id))
                        .adding(UInt16(card))
            case let .horizontal(id, column):
                return Data()
                        .adding(UInt16(id))
                        .adding(UInt8(column))
            case let .remove(id):
                return Data()
                    .adding(UInt16(id))
            case let .drop(column):
                return Data()
                    .adding(UInt8(column))
            }
        }
        
        private var key: Key {
            switch self {
            case .create:
                return .create
            case .card:
                return .card
            case .column:
                return .column
            case .name:
                return .name
            case .content:
                return .content
            case .vertical:
                return .vertical
            case .horizontal:
                return .horizontal
            case .remove:
                return .remove
            case .drop:
                return .drop
            }
        }
    }
}
