import Foundation
import Archivable

extension Board {
    struct State: Property {
        let date: Date
        let actions: [Action]
        
        var data: Data {
            Data()
                .adding(date)
                .adding(UInt8(actions.count))
                .adding(actions.flatMap(\.data))
        }
        
        init() {
            date = .init()
            actions = []
        }
        
        init(data: inout Data) {
            date = data.date()
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
