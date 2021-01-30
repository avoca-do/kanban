import Foundation

extension Board {
    struct Snap: Equatable, Archivable {
        let date: Date
        let actions: [Action]
        let columns: [Column]
        
        var data: Data {
            Data()
                .add(date.timestamp)
                .add(UInt8(actions.count))
                .add(actions.flatMap(\.data))
        }
        
        init(state: [Column]) {
            date = .init()
            actions = []
            columns = state
        }
        
        init(data: inout Data) {
            date = .init(timestamp: data.uInt32())
            actions = (0 ..< .init(data.removeFirst()))
                .map { _ in
                    .init(data: &data)
                }
            columns = []
        }
        
        private init(date: Date, actions: [Action], columns: [Column]) {
            self.date = date
            self.actions = actions
            self.columns = columns
        }
        
        func with(state: [Column]) -> Self {
            .init(date: date, actions: actions, columns: actions.reduce(state) {
                $0.apply($1)
            })
        }
        
        mutating func add(_ action: Action) {
            self = .init(date: .init(), actions: actions + [action], columns: columns.apply(action))
        }
        
        mutating func compress(state: [Column]) {
            
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.date.timestamp == rhs.date.timestamp && lhs.actions == rhs.actions
        }
    }
}
