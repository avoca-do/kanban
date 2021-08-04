import Foundation
import Archivable

extension Board {
    struct Snap: Pather {
        let state: State
        let items: [Column]
        let counter: Int

        init(after: Snap?) {
            state = .init()
            items = after?.items ?? []
            counter = after?.counter ?? 0
        }
        
        init(data: inout Data, after: Snap?) {
            self = {
                $0.actions.reduce(after ?? .init(state: .init(), columns: [], counter: 0)) {
                    $0.applying($1)
                }.with(state: $0)
            } (State(data: &data))
        }
        
        private init(state: State, columns: [Column], counter: Int) {
            self.state = state
            self.items = columns
            self.counter = counter
        }
        
        func path2(_ id: Int) -> Path? {
            //items[id]
            nil
        }
        
        mutating func add(_ action: Action, _ previous: Snap?) {
            self = applying(action)
                    .with(state: state
                            .filtering(action: action, on: self)
                            .validating(action: action, from: previous, to: self))
        }
        
        private func with(state: State) -> Self {
            .init(state: state, columns: items, counter: counter)
        }
        
        private func applying(_ action: Board.Action) -> Self {
            switch action {
            case .create:
                return applying(.column)
                    .applying(.name(0, "DO"))
                    .applying(.column)
                    .applying(.name(1, "DOING"))
                    .applying(.column)
                    .applying(.name(2, "DONE"))
            case .card:
                return .init(state: state, columns: items.mutating(index: 0) {
                                $0.adding(id: counter)
                }, counter: counter + 1)
            case .column:
                return .init(state: state, columns: items + Column(), counter: counter)
            case let .name(column, name):
                return .init(state: state, columns: items.mutating(index: column) {
                    $0.with(name: name)
                }, counter: counter)
            case let .content(id, content):
                return .init(state: state, columns: items.mutating(id: id) {
                    $0.with(content: content)
                }, counter: counter)
            case let .vertical(id, card):
                return .init(state: state, columns: items.moving(id: id, vertical: card), counter: counter)
            case let .horizontal(id, column):
                return .init(state: state, columns: items.moving(id: id, horizontal: column), counter: counter)
            case let .remove(id):
                return .init(state: state, columns: items.removing(id: id), counter: counter)
            case let .drop(column):
                return .init(state: state, columns: items.removing(index: column), counter: counter)
            }
        }
    }
}
