import Foundation

public struct Archive: Archivable {
    public var count: Int {
        boards.count
    }
    
    var id: String
    
    var boards = [Board]() {
        didSet {
            Memory.shared.save.send(self)
        }
    }
    
    var data: Data {
        Data()
            .add(id)
            .add(UInt8(boards.count))
            + boards.flatMap(\.data)
    }
    
    init() {
        id = ""
    }
    
    init(data: inout Data) {
        id = ""
    }
    
    public subscript(_ index: Int) -> Board {
        get {
            boards[index]
        }
        set {
            boards[index] = newValue
        }
    }
    
    public mutating func add() {
        boards.append(.init())
    }
}
