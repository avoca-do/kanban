import Foundation
import Archivable

extension Board {
    enum Action: Archiving, Equatable {
        case
        create,
        card,
        column,
        title(Int, String),
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
            case .title:
                self = .title(.init(data.removeFirst()), data.string())
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
                default: break
                }
            case let .vertical(id, _):
                if case let .vertical(other, _) = action, id == other {
                    return false
                }
            case let .title(column, _):
                if case let .title(other, _) = action, column == other {
                    return false
                }
            case let .remove(id):
                switch action {
                case let .content(other, _), let .horizontal(other, _), let .vertical(other, _):
                    return id != other
                default: break
                }
            case let .drop(column):
                switch action {
                case let .title(other, _):
                    return column != other
                case let .content(id, _), let .vertical(id, _):
                    return column != on.path(id)!._column
                default: break
                }
            default: break
            }
            return true
        }
        
        func redundant(_ from: Snap?, _ to: Snap) -> Bool {
            switch self {
            case let .content(id, content):
                return from.flatMap { snap in
                    snap.path(id).map {
                        snap[$0][$0].content == content
                    }
                } ?? false
            case let .horizontal(id, column):
                if let previous = from?.path(id) {
                    return previous._column == column
                } else {
                    if column == 0 && to.counter == id + 1 {
                        return true
                    }
                }
            case let .vertical(id, card):
                if let previous = from?.path(id) {
                    return previous._column == to.path(id)!._column && previous._card == card
                } else {
                    if to.path(id)!._column == 0, card == 0 && to.counter == id + 1 {
                        return true
                    }
                }
            case let .title(column, title):
                if let from = from, from.columns.count > column, from.columns[column].title == title {
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
        
        var key: Key {
            switch self {
            case .create: return .create
            case .card: return .card
            case .column: return .column
            case .title: return .title
            case .content: return .content
            case .vertical: return .vertical
            case .horizontal: return .horizontal
            case .remove: return .remove
            case .drop: return .drop
            }
        }
    }
}
