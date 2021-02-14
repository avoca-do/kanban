import Foundation

extension Board {
    struct Snap {
        let state: State
        let columns: [Column]
        let counter: Int

        init(after: Snap?) {
            state = .init()
            columns = after?.columns ?? []
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
            self.columns = columns
            self.counter = counter
        }
        
        func path(_ id: Int) -> Path? {
            columns[id]
        }
        
        subscript(_ path: Path) -> Column {
            path._column >= 0 && path._column < columns.count ? columns[path._column] : .init()
        }
        
        mutating func add(_ action: Action, _ previous: Snap?) {
            self = applying(action)
                .with(state: state
                        .filtering(action: action, on: self)
                        .validating(action: action, from: previous, to: self))
        }
        
        private func with(state: State) -> Self {
            .init(state: state, columns: columns, counter: counter)
        }
        
        private func applying(_ action: Board.Action) -> Self {
            switch action {
            case .create:
                return applying(.column)
                    .applying(.title(0, "DO"))
                    .applying(.column)
                    .applying(.title(1, "DOING"))
                    .applying(.column)
                    .applying(.title(2, "DONE"))
            case .card:
                return .init(state: state, columns: columns.mutating(index: 0) {
                                $0.adding(id: counter)
                }, counter: counter + 1)
            case .column:
                return .init(state: state, columns: columns + Column(), counter: counter)
            case let .title(column, title):
                return .init(state: state, columns: columns.mutating(index: column) {
                    $0.with(title: title)
                }, counter: counter)
            case let .content(id, content):
                return .init(state: state, columns: columns.mutating(id: id) {
                    $0.with(content: content)
                }, counter: counter)
            case let .vertical(id, card):
                return .init(state: state, columns: columns.moving(id: id, vertical: card), counter: counter)
            case let .horizontal(id, column):
                return .init(state: state, columns: columns.moving(id: id, horizontal: column), counter: counter)
            case let .remove(id):
                return .init(state: state, columns: columns.removing(id: id), counter: counter)
            case let .drop(column):
                return .init(state: state, columns: columns.removing(index: column), counter: counter)
            }
        }
    }
}
