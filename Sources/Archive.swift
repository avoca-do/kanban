import Foundation

public struct Archive: Archivable {
    public var count: Int {
        boards.count
    }
    
    var date: Date
    
    var boards: [Board] {
        didSet {
            date = .init()
            Memory.shared.save.send(self)
        }
    }
    
    var data: Data {
        Data()
            .add(date.timestamp)
            .add(UInt8(boards.count))
            .add(boards.flatMap(\.data))
            .compressed
    }
    
    init() {
        date = .init()
        boards = []
    }
    
    init(data: inout Data) {
        data.decompress()
        date = .init(timestamp: data.uInt32())
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
