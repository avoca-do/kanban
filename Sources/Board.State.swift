import Foundation

extension Board {
    struct State: Archivable {
        let date: Date
        let actions: [Action]
        
        var data: Data {
            Data()
                .adding(date.timestamp)
                .adding(UInt8(actions.count))
                .adding(actions.flatMap(\.data))
        }
        
        init() {
            date = .init()
            actions = []
        }
        
        init(data: inout Data) {
            date = .init(timestamp: data.uInt32())
            actions = (0 ..< .init(data.removeFirst()))
                .map { _ in
                    .init(data: &data)
                }
        }
        
        private init(date: Date, actions: [Action]) {
            self.date = date
            self.actions = actions
        }
        
        func filtering(action: Action, on: Snap) -> Self {
            .init(date: date, actions: actions.filter {
                action.allows($0, on: on)
            })
        }
        
        func validating(action: Action, from: Snap?, to: Snap) -> Self {
            action.redundant(from, to) ? .init(date: .init(), actions: actions) : .init(date: .init(), actions: actions + action)
        }
    }
}
