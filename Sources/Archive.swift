import Foundation

public struct Archive {
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
        .init()
    }
    
    init() {
        id = ""
    }
    
    init(data: Data) {
        fatalError()
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
