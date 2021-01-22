import Foundation

public struct User {
    public internal(set) var boards = [Board]()
    var id = ""
    var deleted = [Int]()
    var counter = Int()
    
    public mutating func new() -> Int {
        boards.append(.init(id: counter))
        counter += 1
        Memory.shared.update.send(self)
        Memory.shared.save.send(boards.last!)
        return boards.last!.id
    }
    
    public mutating func rename(_ id: Int, _ name: String) {
        self[id].add(.rename(name))
        Memory.shared.update.send(self)
        Memory.shared.save.send(self[id])
    }
    
    private subscript(_ id: Int) -> Board {
        get {
            boards[boards.firstIndex { $0.id == id }!]
        }
        set {
            boards[boards.firstIndex { $0.id == id }!] = newValue
        }
    }
}
