import Foundation
import Archivable

public struct Board: Property, Pather, PatherItem {
    public let name: String
    let snaps: [Snap]
    
    public var items: [Column] {
        snaps.last!.items
    }
    
    func with(name: String) -> Self {
        .init(name: name, snaps: snaps)
    }
    
    func with(snaps: [Snap]) -> Self {
        .init(name: name, snaps: snaps)
    }
    
    private init(name: String, snaps: [Snap]) {
        self.name = name
        self.snaps = snaps
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
    

    public init() {
        name = ""
        snaps = ([Snap]()).adding(action: .create)
    }
    
    public init(data: inout Data) {
        name = data.string()
        snaps = (0 ..< .init(data.uInt16())).reduce(into: []) { list, _ in
            list.append(Snap(data: &data, after: list.last))
        }
    }
    
    mutating func move(_ path: Path, vertical: Int) {
        guard path._card != vertical else { return }
//        add(.vertical(self[path][path].id, vertical))
    }
    
    mutating func move(_ path: Path, horizontal: Int) {
        guard path._column != horizontal else { return }
//        add(.horizontal(self[path][path].id, horizontal))
    }
    
    mutating func remove(_ path: Path) {
//        guard snap.path(self[path][path].id) != nil else { return }
//        add(.remove(self[path][path].id))
    }
    
    mutating func drop(_ path: Path) {
//        add(.drop(path._column))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.items == rhs.items
    }
}
