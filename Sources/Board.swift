import Foundation

public struct Board: Equatable, Archivable {
    public var name: String
    
    public var count: Int {
        snaps.last!.columns.count
    }
    
    public var isEmpty: Bool {
        snaps.last!.columns.isEmpty
    }
    
    public var date: Date {
        snaps.last!.state.date
    }
    
    public var progress: Progress {
        {
            .init(cards: $0, done: $1, percentage: $0 > 0 ? .init($1) / .init($0) : 0)
        } (snaps.last!.columns.map(\.count).reduce(0, +), snaps.last!.columns.last!.count)
    }
    
    var snaps: [Snap]
    
    var data: Data {
        Data()
            .adding(name)
            .adding(UInt16(snaps.count))
            .adding(snaps.map(\.state).flatMap(\.data))
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
    
    public subscript(_ index: Int) -> Column {
        snaps.last!.columns[index]
    }
    
    public subscript(_ column: Int, _ index: Int) -> String {
        get {
            snaps.last![.init(column: column, index: index)]
        }
        set {
            let content = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                !content.isEmpty,
                content != snaps.last![.init(column: column, index: index)]
            else { return }
            add(.content(snaps.last![.init(column: column, index: index)], content))
        }
    }
    
    public subscript(vertical column: Int, _ index: Int) -> Int {
        get {
            index
        }
        set {
            guard index != newValue else { return }
            add(.vertical(snaps.last![.init(column: column, index: index)], newValue))
        }
    }
    
    public subscript(horizontal column: Int, _ index: Int) -> Int {
        get {
            column
        }
        set {
            guard column != newValue else { return }
            add(.horizontal(snaps.last![.init(column: column, index: index)], newValue))
        }
    }
    
    public mutating func column() {
        add(.column)
    }
    
    public mutating func card() {
        add(.card)
    }
    
    public mutating func remove(column: Int, index: Int) {
        add(.remove(snaps.last![.init(column: column, index: index)]))
    }
    
    public mutating func title(column: Int, _ title: String) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !title.isEmpty,
            title != self[column].title
        else { return }
        add(.title(column, title))
    }
    
    public mutating func drop(column: Int) {
        add(.drop(column))
    }
    
    private mutating func add(_ action: Action) {
        if snaps.isEmpty || Calendar.current.dateComponents([.hour], from: snaps.last!.state.date, to: .init()).hour! > 0 {
            snaps.append(.init(after: snaps.last))
        }
        snaps[snaps.count - 1].add(action, snaps.count > 1 ? snaps[snaps.count - 2] : nil)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.snaps.last!.columns == rhs.snaps.last!.columns
    }
}
