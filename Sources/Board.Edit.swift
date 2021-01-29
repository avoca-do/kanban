import Foundation

extension Board {
    struct Edit: Equatable, Archivable {
        var date: Date
        var actions: [Action]
        
        var data: Data {
            Data()
                .add(date.timestamp)
                .add(UInt8(actions.count))
                .add(actions.flatMap(\.data))
        }
        
        init(action: Action) {
            date = .init()
            actions = [action]
        }
        
        init(data: inout Data) {
            date = .init(timestamp: data.uInt32())
            actions = (0 ..< .init(data.removeFirst()))
                .map { _ in
                    .init(data: &data)
                }
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.date.timestamp == rhs.date.timestamp && lhs.actions == rhs.actions
        }
    }
}
