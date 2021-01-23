import Foundation

extension User {
    struct Descriptor: Describe {
        let id: String
        let counter: Int
        let date: Date
        let boards: [Board]
        
        init?(data: Data) {
            nil
        }
        
        init(describe: User) {
            id = describe.id
            counter = describe.counter
            date = describe.date
            boards = []
        }
        
        var data: Data {
            .init()
        }
        
    }
}
