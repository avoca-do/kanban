import Foundation

extension Board {
    struct State: Equatable, Archivable {
        let date: Date
        let actions: [Action]
        
        var data: Data {
            Data()
                .add(date.timestamp)
                .add(UInt8(actions.count))
                .add(actions.flatMap(\.data))
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
        
        func adding(_ action: Action) -> Self {
            .init(date: .init(), actions: actions + action)
        }
    }
}
