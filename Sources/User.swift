import Foundation

public struct User: Codable {
    var id = ""
    public private(set) var boards = [Bool]()
    
    public mutating func board(_ name: String) -> Board {
        let board = Board(name: name, id: boards.count)
        boards.append(true)
        Memory.shared.save.send(board)
        return board
    }
}
