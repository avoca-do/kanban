import Foundation

extension Board {
    struct Snap: Equatable {
        let state: State
        let columns: [Column]
        private let counter: Int

        init(after: Snap?) {
            state = .init()
            columns = after?.columns ?? []
            counter = after?.counter ?? 0
        }
        
        init(data: inout Data, after: Snap?) {
            self = {
                $0.actions.reduce(after ?? .init(state: .init(), columns: [], counter: 0)) {
                    $0.applying($1)
                }.with($0)
            } (State(data: &data))
        }
        
        private init(state: State, columns: [Column], counter: Int) {
            self.state = state
            self.columns = columns
            self.counter = counter
        }
        
        mutating func add(_ action: Action) {
            self = applying(action)
                .with(state.adding(action))
        }
        
        private func with(_ state: State) -> Self {
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
            case let .vertical(id, index):
                return .init(state: state, columns: columns.vertical(id: id, to: index), counter: counter)
            case let .horizontal(id, column):
                return .init(state: state, columns: columns.horizontal(id: id, to: column), counter: counter)
            }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.state == rhs.state
        }
    }
}
