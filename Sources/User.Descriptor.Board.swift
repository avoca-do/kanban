import Foundation

extension User.Descriptor {
    struct Board: Datable {
        let id: Int
        let date: Date
        
        var data: Data {
            .init()
        }
        
        init?(data: Data) {
            nil
        }
        
        init(board: Kanban.Board) {
            id = board.id
            date = board.edit.last!.date
        }
    }
}
