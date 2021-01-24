import Foundation

extension User {
    struct Descriptor: Describe {
        let id: String
        let counter: Int
        let date: Date
        let boards: [Board]
        
        var described: User {
            .init(descriptor: self)
        }
        
        init(data: Data) {
            fatalError()
        }
        
        init(describe: User) {
            id = describe.id
            counter = describe.counter
            date = describe.date
            boards = describe.boards.map(Board.init(board:))
        }
        
        var data: Data {
            Data()
                .add(id)
                .add(UInt16(counter))
                .add(date.timestamp)
                .add(UInt8(boards.count))
                + boards.flatMap(\.data)
        }
    }
}
