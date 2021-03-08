import Foundation

public struct Archive: Archivable, Comparable {
    public var available: Bool {
        capacity > boards.count
    }
    
    public var capacity = 1 {
        didSet {
            Memory.shared.save.send(self)
        }
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
            .adding(UInt16(capacity))
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
        capacity = .init(data.uInt16())
    }
    
    public func isEmpty(_ path: Path) -> Bool {
        switch path {
        case .archive: return boards.isEmpty
        case .board: return self[path].isEmpty
        case .column: return self[path][path].isEmpty
        default: return true
        }
    }
    
    public func count(_ path: Path) -> Int {
        switch path {
        case .archive: return boards.count
        case .board: return self[path].count
        case .column: return self[path][path].count
        default: return 0
        }
    }
    
    public func date(_ path: Path) -> Date {
        switch path {
        case .board: return self[path].date
        default: return boards.map(\.date).max() ?? .distantPast
        }
    }
    
    public func progress(_ path: Path) -> Progress {
        self[path].progress
    }
    
    public subscript(name path: Path) -> String {
        get {
            self[path].name
        }
        set {
            self[path].name = newValue
        }
    }
    
    public subscript(title path: Path) -> String {
        get {
            self[path][title: path]
        }
        set {
            self[path][title: path] = newValue
        }
    }
    
    public subscript(content path: Path) -> String {
        get {
            self[path][content: path]
        }
        set {
            self[path][content: path] = newValue
        }
    }
    
    public subscript(activity period: Period) -> [[Double]] {
        []
    }
    
    public mutating func move(_ path: Path, vertical: Int) {
        self[path].move(path, vertical: vertical)
    }
    
    public mutating func move(_ path: Path, horizontal: Int) {
        self[path].move(path, horizontal: horizontal)
    }
    
    public mutating func add() {
        boards.insert(.init(), at: 0)
    }
    
    public mutating func delete(_ path: Path) {
        boards.remove(at: path._board)
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

    public mutating func drop(_ path: Path) {
        self[path].drop(path)
    }
    
    public static func < (lhs: Archive, rhs: Archive) -> Bool {
        lhs.date(.archive) < rhs.date(.archive) && lhs.capacity <= rhs.capacity
    }
    
    subscript(_ path: Path) -> Board {
        get {
            path._board >= 0 && path._board < boards.count ? boards[path._board] : .init()
        }
        set {
            boards[path._board] = newValue
        }
    }
}
