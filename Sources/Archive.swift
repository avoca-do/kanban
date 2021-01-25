import Foundation

public struct Archive: Archivable {
    public var count: Int {
        boards.count
    }
    
    var id: String
    
    var boards: [Board] {
        didSet {
            Memory.shared.save.send(self)
        }
    }
    
    var data: Data {
        Data()
            .add(id)
            .add(UInt8(boards.count))
            .add(boards.flatMap(\.data))
            .compressed
    }
    
    init() {
        id = ""
        boards = []
    }
    
    init(data: inout Data) {
        data.decompress()
        id = data.string()
        boards = (0 ..< .init(data.removeFirst()))
            .map { _ in
                .init(data: &data)
            }
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
