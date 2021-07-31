import Foundation
import Archivable

public struct Board: Property, Pather, PatherItem {
    public let name: String
    let snaps: [Snap]
    
    public var items: [Column] {
        snap.items
    }
    
    func with(name: String) -> Self {
        .init(name: name, snaps: snaps)
    }
    
    private init(name: String, snaps: [Snap]) {
        self.name = name
        self.snaps = snaps
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var date: Date {
        snap.state.date
    }
    
    var progress: Progress {
        {
            Progress(cards: $0, done: $1, percentage: $0 > 0 ? .init($1) / .init($0) : 0)
        } (items.map(\.count).reduce(0, +), items.last!.count)
    }
    
    
    
    public var data: Data {
        Data()
            .adding(name)
            .adding(UInt16(snaps.count))
            .adding(snaps.map(\.state).flatMap(\.data))
    }
    
    
    
    private var snap: Snap {
        snaps.last!
    }
    
    public init() {
        name = ""
        snaps = []
        add(.create)
    }
    
    public init(data: inout Data) {
        name = data.string()
        snaps = (0 ..< .init(data.uInt16())).reduce(into: []) { list, _ in
            list.append(Snap(data: &data, after: list.last))
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
        if snaps.isEmpty || (Calendar.current.dateComponents([.hour], from: date, to: .init()).hour! > 0
                                && !snap.state.actions.isEmpty) {
            snaps.append(.init(after: snaps.last))
        }
        snaps[snaps.count - 1].add(action, snaps.count > 1 ? snaps[snaps.count - 2] : nil)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.items == rhs.items
    }
}
