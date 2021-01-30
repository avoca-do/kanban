import Foundation

extension Board {
    struct Snap: Equatable, Archivable {
        let date: Date
        let actions: [Action]
        let state: [Column]
        
        var data: Data {
            Data()
                .add(date.timestamp)
                .add(UInt8(actions.count))
                .add(actions.flatMap(\.data))
        }
        
        init(state: [Column]) {
            date = .init()
            actions = []
            self.state = state
        }
        
        init(data: inout Data) {
            date = .init(timestamp: data.uInt32())
            actions = (0 ..< .init(data.removeFirst()))
                .map { _ in
                    .init(data: &data)
                }
            state = []
        }
        
        private init(date: Date, actions: [Action], state: [Column]) {
            self.date = date
            self.actions = actions
            self.state = state
        }
        
        func with(state: [Column]) -> Self {
            .init(date: date, actions: actions, state: state)
        }
        
        mutating func add(_ action: Action) {
            self = .init(date: .init(), actions: actions + [action], state: state)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.date.timestamp == rhs.date.timestamp && lhs.actions == rhs.actions
        }
    }
}
