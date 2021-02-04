import Foundation

public struct Archive: Archivable, Comparable {
    public var count: Int {
        boards.count
    }
    
    public var isEmpty: Bool {
        boards.isEmpty
    }
    
    public var date: Date {
        boards.map(\.date).max() ?? .distantPast
    }
    
    var boards: [Board] {
        didSet {
            Memory.shared.save.send(self)
        }
    }
    
    var data: Data {
        Data()
            .adding(UInt8(boards.count))
            .adding(boards.flatMap(\.data))
            .compressed
    }
    
    public init() {
        boards = []
    }
    
    init(data: inout Data) {
        data.decompress()
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
        boards.insert(.init(), at: 0)
    }
    
    public static func < (lhs: Archive, rhs: Archive) -> Bool {
        lhs.date < rhs.date
    }
}
