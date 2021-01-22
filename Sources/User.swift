import Foundation

public struct User {
    var id = ""
    public internal(set) var boards = [Order]()
    var deleted = [UInt16]()
    private(set) var counter = UInt16()
    
    public mutating func board(_ name: String) -> Board {
        let board = Board(name: name, id: counter)
        boards.append(.init(id: counter, update: Date().timestamp))
        counter += 1
        Memory.shared.update.send(self)
        Memory.shared.save.send(board)
        return board
    }
}
