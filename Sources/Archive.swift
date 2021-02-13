import Foundation

public struct Archive: Archivable, Comparable {
    var boards: [Board] {
        didSet {
            Memory.shared.save.send(self)
        }
    }
    
    var date: Date {
        boards.map(\.date).max() ?? .distantPast
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
    
    public subscript(_ path: Path) -> Bool {
        boards.isEmpty
    }
    
    public subscript(_ path: Path) -> Int {
        boards.count
    }
    
    public subscript(_ path: Path) -> Date {
        date
    }
    
    public subscript(_ path: Path) -> Progress {
        path.board < boards.count ? boards[path.board].progress : .init(cards: 0, done: 0, percentage: 0)
    }
    
    public subscript(_ path: Path) -> String {
        get {
            path.board < boards.count ? boards[path.board][path] : ""
        }
        set {
            boards[path.board][path] = newValue
        }
    }
    
    public subscript(vertical path: Path) -> Int {
        get {
            path.card
        }
        set {
            boards[path.board][vertical: path] = newValue
        }
    }
    
    public subscript(horizontal path: Path) -> Int {
        get {
            path.column
        }
        set {
            boards[path.board][horizontal: path] = newValue
        }
    }
    
    public mutating func add() {
        boards.insert(.init(), at: 0)
    }
    
    public mutating func delete(board: Int) {
        boards.remove(at: board)
    }
    
    public mutating func column(_ path: Path) {
        boards[path.board].column()
    }
    
    public mutating func card(_ path: Path) {
        boards[path.board].card()
    }
    
    public mutating func remove(_ path: Path) {
        boards[path.board].remove(path)
    }
    
    public mutating func change(_ path: Path, title: String) {
        boards[path.board].change(path, title: title)
    }
    
    public mutating func drop(_ path: Path) {
        boards[path.board].drop(path)
    }
    
    public static func < (lhs: Archive, rhs: Archive) -> Bool {
        lhs.date < rhs.date
    }
}
