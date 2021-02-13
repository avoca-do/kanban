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
    
    subscript(_ path: Path) -> Bool {
        isEmpty
    }
    
    subscript(_ path: Path) -> Int {
        count
    }
    
    subscript(_ path: Path) -> String {
        get {
            snaps.last![path]
        }
        set {
            let content = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                !content.isEmpty,
                content != snaps.last![path]
            else { return }
            add(.content(snaps.last![path], content))
        }
    }
    
    subscript(vertical path: Path) -> Int {
        get {
            path.card
        }
        set {
            guard path.card != newValue else { return }
            add(.vertical(snaps.last![path], newValue))
        }
    }
    
    subscript(horizontal path: Path) -> Int {
        get {
            path.column
        }
        set {
            guard path.column != newValue else { return }
            add(.horizontal(snaps.last![path], newValue))
        }
    }
    
    mutating func column() {
        add(.column)
    }
    
    mutating func card() {
        add(.card)
    }
    
    mutating func remove(_ path: Path) {
        add(.remove(snaps.last![path]))
    }
    
    mutating func change(_ path: Path, title: String) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !title.isEmpty,
            title != self[path].title
        else { return }
        add(.title(path.column, title))
    }
    
    mutating func drop(_ path: Path) {
        add(.drop(path.column))
    }
    
    mutating func add(_ action: Action) {
        if snaps.isEmpty || Calendar.current.dateComponents([.hour], from: snaps.last!.state.date, to: .init()).hour! > 0 {
            snaps.append(.init(after: snaps.last))
        }
        snaps[snaps.count - 1].add(action, snaps.count > 1 ? snaps[snaps.count - 2] : nil)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.columns == rhs.columns
    }
}
