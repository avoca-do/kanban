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
            var data = data
            id = data.string()
            counter = .init(data.uInt16())
            date = .init(timestamp: data.uInt32())
            boards = (0 ..< .init(data.removeFirst())).map { _ in
                .init(id: .init(data.uInt16()), date: .init(timestamp: data.uInt32()))
            }
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
                + boards.flatMap {
                    Data()
                        .add(UInt16($0.id))
                        .add($0.date.timestamp)
                }
        }
    }
}
