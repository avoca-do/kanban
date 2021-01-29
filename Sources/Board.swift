import Foundation

public struct Board: Hashable, Archivable {
    public private(set) var name: String
    
    public var count: Int {
        columns.count
    }
    
    public var isEmpty: Bool {
        columns.isEmpty
    }
    
    public var date: Date {
        edit.last!.date
    }
    
    var edit: [Edit]
    var columns: [Column]
    
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
    
    public mutating func content(card: Card, text: String) {
        add(.content(card, text))
    }
    
    public mutating func vertical(card: Card, order: Int) {
        add(.vertical(card, order))
    }
    
    public mutating func horizontal(card: Card, column: Int) {
        add(.horizontal(card, column))
    }
    
    private mutating func add(_ action: Action) {
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
    
    private mutating func perform(_ action: Action) {
        switch action {
        case .create:
            perform(.column)
            perform(.title(0, "DO"))
            perform(.column)
            perform(.title(1, "DOING"))
            perform(.column)
            perform(.title(2, "DONE"))
        case .card:
            columns[0].cards.insert("", at: 0)
        case .column:
            columns.append(.init())
        case let .rename(name):
            self.name = name
        case let .title(column, title):
            columns[column].title = title
        case let .content(card, text):
            columns[card.column].cards[card.order] = text
        case let .vertical(card, order):
            columns[card.column].cards.insert(columns[card.column].cards.remove(at: card.order), at: order)
        case let .horizontal(card, column):
            columns[column].cards.insert(columns[card.column].cards.remove(at: card.order), at: 0)
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
