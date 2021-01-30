import Foundation

public struct Board: Hashable, Archivable {
    public var name: String
    
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
    
    public mutating func content(card: Index, text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            !text.isEmpty,
            text != self[card.column][card.order]
        else { return }
        edit[edit.count - 1].actions.removeAll {
            if case let .content(previous, _) = $0, previous == card {
                return true
            }
            return false
        }
        add(.content(card, text))
    }
    
    public mutating func vertical(card: Index, order: Int) {
        guard card.order != order else { return }
        add(.vertical(card, order))
        
        var card = card
        edit[edit.count - 1].actions = edit[edit.count - 1].actions.dropLast().reversed().reduce(into: []) {
            if case let .vertical(previous, index) = $1, previous.column == card.column, index == card.order {
                card.order = previous.order
            } else {
                $0.append($1)
            }
        }.reversed() + [.vertical(card, order)]
    }
    
    public mutating func horizontal(card: Index, column: Int) {
        guard card.column != column else { return }
        add(.horizontal(card, column))
        
        var card = card
        edit[edit.count - 1].actions = edit[edit.count - 1].actions.dropLast().reversed().reduce(into: []) {
            if case let .horizontal(previous, index) = $1, index == card.column {
                card = previous
            } else if case let .vertical(previous, index) = $1, previous.column == card.column, index == card.order {
                card = previous
            } else {
                $0.append($1)
            }
        }.reversed() + [.horizontal(card, column)]
    }
    
    private mutating func add(_ action: Action) {
        if let last = edit.last {
            if Calendar.current.dateComponents([.hour], from: last.date, to: .init()).hour! > 0 {
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
            perform(.column)
            perform(.column)
            columns[0].title = "DO"
            columns[1].title = "DOING"
            columns[2].title = "DONE"
        case .card:
            columns[0].cards.insert(.init(), at: 0)
        case .column:
            columns.append(.init())
        case let .content(card, text):
            columns[card.column].cards[card.order].content = text
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
