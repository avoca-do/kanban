import Foundation

public struct Archive: Archivable, Hashable {
    public var count: Int {
        boards.count
    }
    
    var date: Date {
        boards.map(\.date).max() ?? .init()
    }
    
    var boards: [Board] {
        didSet {
            Memory.shared.save.send(self)
        }
    }
    
    var data: Data {
        Data()
            .add(UInt8(boards.count))
            .add(boards.flatMap(\.data))
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
        boards.append(.init())
    }
    
    public func hash(into: inout Hasher) {
        into.combine(date)
        into.combine(boards)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.date == rhs.date && lhs.boards == rhs.boards
    }
}
