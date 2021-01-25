import Foundation

extension Board {
    struct Edit: Archivable {
        var date: Date
        var actions: [Action]
        
        var data: Data {
            Data()
                .add(date.timestamp)
                .add(UInt8(actions.count))
                + actions.flatMap(\.data)
        }
        
        init(action: Action) {
            date = .init()
            actions = [action]
        }
        
        init(data: inout Data) {
            fatalError()
        }
    }
}
