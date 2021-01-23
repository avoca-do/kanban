import Foundation

public struct User: Synchable {
    public internal(set) var boards = [Board]()
    var id: String
    var date: Date
    var counter = Int()
    
    init?(data: Data) {
        nil
    }
    
    init(descriptor: Descriptor) {
        fatalError()
    }
    
    init() {
        id = ""
        date = .init()
    }
    
    var data: Data {
        .init()
    }
    
    var descriptor: Descriptor {
        .init(describe: self)
    }
    
    public mutating func new() -> Int {
        boards.append(.init(id: counter))
        counter += 1
        date = .init()
        Memory.shared.update.send(self)
        Memory.shared.save.send(boards.last!)
        return boards.last!.id
    }
    
    public mutating func rename(_ id: Int, _ name: String) {
        self[id].add(.rename(name))
        date = .init()
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
