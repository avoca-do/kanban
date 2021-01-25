import Foundation

public struct Board: Hashable, Archivable {
    public private(set) var name: String
    
    public var count: Int {
        columns.count
    }
    
    var edit: [Edit]
    private var columns: [Column]
    
    var data: Data {
        Data()
            .add(name)
            .add(UInt16(edit.count))
            .add(edit.flatMap(\.data))
    }
    
    init() {
        name = ""
        columns = []
        edit = []
        add(.create)
    }
    
    init(data: inout Data) {
        name = data.string()
        columns = []
        edit = (0 ..< .init(data.uInt16()))
            .map { _ in
                .init(data: &data)
            }
        edit.flatMap(\.actions).forEach {
            perform($0)
        }
    }
    
    public subscript(_ index: Int) -> Column {
        columns[index]
    }
    
    public mutating func card() {
        add(.card)
    }
    
    public mutating func rename(_ name: String) {
        add(.rename(name))
    }
    
    private mutating func add(_ action: Edit.Action) {
        if let last = edit.last {
            if Calendar.current.dateComponents([.minute], from: last.date, to: .init()).minute! > 4 {
                edit.append(.init(action: action))
            } else {
                edit[edit.count - 1].actions.append(action)
            }
        } else {
            edit.append(.init(action: action))
        }
        
        perform(action)
    }
    
    private mutating func perform(_ action: Edit.Action) {
        switch action {
        case .create:
            perform(.column)
            perform(.title(0, "Do"))
            perform(.column)
            perform(.title(1, "Doing"))
            perform(.column)
            perform(.title(2, "Done"))
        case .card:
            break
        case .column:
            columns.append(.init())
        case let .rename(name):
            self.name = name
        case let .title(index, title):
            columns[index].title = title
        case .move:
            break
        case .content:
            break
        }
    }
    
    public func hash(into: inout Hasher) {
        into.combine(name)
        into.combine(columns)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.columns == rhs.columns
    }
}
