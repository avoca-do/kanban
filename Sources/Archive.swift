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
        Data()
            .add(id)
            .add(UInt8(boards.count))
            + boards.flatMap {
                Data()
                    .add($0.name)
                    .add(UInt16($0.edit.count))
                    + $0.edit.flatMap {
                        Data()
                            .add($0.date.timestamp)
                            .add(UInt8($0.actions.count))
                            + $0.actions.flatMap {
                                Data()
                                    .add($0.value)
                                
                            }
                    }
            }
    }
    
    init() {
        id = ""
    }
    
    init(data: Data) {
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
