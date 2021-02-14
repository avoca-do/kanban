import Foundation

struct Board: Archivable, Equatable {
    var name: String
    
    var count: Int {
        columns.count
    }
    
    var isEmpty: Bool {
        columns.isEmpty
    }
    
    var date: Date {
        snap.state.date
    }
    
    var progress: Progress {
        {
            .init(cards: $0, done: $1, percentage: $0 > 0 ? .init($1) / .init($0) : 0)
        } (columns.map(\.count).reduce(0, +), columns.last!.count)
    }
    
    var snaps: [Snap]
    
    var data: Data {
        Data()
            .adding(name)
            .adding(UInt16(snaps.count))
            .adding(snaps.map(\.state).flatMap(\.data))
    }
    
    private var columns: [Column] {
        snap.columns
    }
    
    private var snap: Snap {
        snaps.last!
    }
    
    init() {
        name = ""
        snaps = []
        add(.create)
    }
    
    init(data: inout Data) {
        name = data.string()
        snaps = (0 ..< .init(data.uInt16())).reduce(into: []) { list, _ in
            list.append(Snap(data: &data, after: list.last))
        }
    }
    
    subscript(_ path: Path) -> Column {
        path._column >= 0 && path._column < count ? columns[path._column] : .init()
    }
    
    subscript(content path: Path) -> String {
        get {
            self[path][path].content
        }
        set {
            let content = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                !content.isEmpty,
                content != self[path][path].content
            else { return }
            add(.content(self[path][path].id, content))
        }
    }
    
    subscript(title path: Path) -> String {
        get {
            self[path].title
        }
        set {
            let title = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                !title.isEmpty,
                title != self[path].title
            else { return }
            add(.title(path._column, title))
        }
    }
    
    mutating func move(_ path: Path, vertical: Int) {
        guard path._card != vertical else { return }
        add(.vertical(self[path][path].id, vertical))
    }
    
    mutating func move(_ path: Path, horizontal: Int) {
        guard path._column != horizontal else { return }
        add(.horizontal(self[path][path].id, horizontal))
    }
    
    mutating func column() {
        add(.column)
    }
    
    mutating func card() {
        add(.card)
    }
    
    mutating func remove(_ path: Path) {
        guard snap.path(self[path][path].id) != nil else { return }
        add(.remove(self[path][path].id))
    }
    
    mutating func drop(_ path: Path) {
        add(.drop(path._column))
    }
    
    mutating func add(_ action: Action) {
        if snaps.isEmpty || Calendar.current.dateComponents([.hour], from: date, to: .init()).hour! > 0 {
            snaps.append(.init(after: snaps.last))
        }
        snaps[snaps.count - 1].add(action, snaps.count > 1 ? snaps[snaps.count - 2] : nil)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.columns == rhs.columns
    }
}
