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
        self[path].progress
    }
    
    public subscript(title path: Path) -> String {
        self[path][path].title
    }
    
    public subscript(_ path: Path) -> String {
        self[path][path][path].content
    }
    
    public subscript(name path: Path) -> String {
        get {
            self[path].name
        }
        set {
            self[path].name = newValue
        }
    }
    
    public subscript(vertical path: Path) -> Int {
        get {
            path.card
        }
        set {
            self[path][vertical: path] = newValue
        }
    }
    
    public subscript(horizontal path: Path) -> Int {
        get {
            path.column
        }
        set {
            self[path][horizontal: path] = newValue
        }
    }
    
    public mutating func add() {
        boards.insert(.init(), at: 0)
    }
    
    public mutating func delete(board: Int) {
        boards.remove(at: board)
    }
    
    public mutating func column(_ path: Path) {
        self[path].column()
    }
    
    public mutating func card(_ path: Path) {
        self[path].card()
    }
    
    public mutating func remove(_ path: Path) {
        self[path].remove(path)
    }
    
    public mutating func change(_ path: Path, title: String) {
        self[path].change(path, title: title)
    }
    
    public mutating func drop(_ path: Path) {
        self[path].drop(path)
    }
    
    public static func < (lhs: Archive, rhs: Archive) -> Bool {
        lhs.date < rhs.date
    }
    
    subscript(_ path: Path) -> Board {
        get {
            path.board < boards.count ? boards[path.board] : .init()
        }
        set {
            boards[path.board] = newValue
        }
    }
}
