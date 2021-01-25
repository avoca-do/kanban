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
                .add(value)
                + content
        }
        
        init(data: inout Data) {
            fatalError()
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
        
        private var value: UInt8 {
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
