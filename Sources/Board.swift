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
    
    var snaps: [Snap]
    
    var data: Data {
        Data()
            .add(name)
            .add(UInt16(snaps.count))
            .add(snaps.map(\.state).flatMap(\.data))
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
    
    public mutating func card() {
        add(.card)
    }
    
    public subscript(_ column: Int, _ index: Int) -> String {
        get {
            snaps.last!.columns[column][index]
        }
        set {
            let content = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                !content.isEmpty,
                content != snaps.last!.columns[column][index]
            else { return }
            add(.content(snaps.last!.columns[column][index], content))
        }
    }
    
    public subscript(vertical column: Int, _ index: Int) -> Int {
        get {
            index
        }
        set {
            guard index != newValue else { return }
            add(.vertical(snaps.last!.columns[column][index], newValue))
        }
    }
    
    public subscript(horizontal column: Int, _ index: Int) -> Int {
        get {
            column
        }
        set {
            guard column != newValue else { return }
            add(.horizontal(snaps.last!.columns[column][index], newValue))
        }
    }
    
    private mutating func add(_ action: Action) {
        if snaps.isEmpty || Calendar.current.dateComponents([.hour], from: snaps.last!.state.date, to: .init()).hour! > 0 {
            snaps.append(.init(after: snaps.last))
        }
        snaps[snaps.count - 1].add(action)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.snaps.last!.columns == rhs.snaps.last!.columns
    }
}
