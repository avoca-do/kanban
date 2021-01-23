import Foundation

extension User.Descriptor {
    struct Board {
        let id: Int
        let date: Date
        
        init(board: Kanban.Board) {
            id = board.id
            date = board.edit.last!.date
        }
    }
}
