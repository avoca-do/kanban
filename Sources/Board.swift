import Foundation

public struct Board: Hashable, Archivable {
    public var name: String
    
    public var count: Int {
        snaps.last!.columns.count
    }
    
    public var isEmpty: Bool {
        snaps.last!.columns.isEmpty
    }
    
    public var date: Date {
        snaps.last!.date
    }
    
    var snaps: [Snap]
    
    var data: Data {
        Data()
            .add(name)
            .add(UInt16(snaps.count))
            .add(snaps.flatMap(\.data))
    }
    
    init() {
        name = ""
        snaps = []
        add(.create)
    }
    
    init(data: inout Data) {
        name = data.string()
        snaps = (0 ..< .init(data.uInt16())).reduce(into: []) {
            $0.append(Snap(data: &data).with(state: $1 == 0 ? [] : $0[$1 - 1].columns))
        }
    }
    
    public subscript(_ index: Int) -> Column {
        snaps.last!.columns[index]
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
//        edit[edit.count - 1].actions.removeAll {
//            if case let .content(previous, _) = $0, previous == card {
//                return true
//            }
//            return false
//        }
        add(.content(card, text))
    }
    
    public mutating func vertical(card: Index, order: Int) {
        guard card.order != order else { return }
        add(.vertical(card, order))
        
//        var card = card
//        edit[edit.count - 1].actions = edit[edit.count - 1].actions.dropLast().reversed().reduce(into: []) {
//            if case let .vertical(previous, index) = $1, previous.column == card.column, index == card.order {
//                card.order = previous.order
//            } else {
//                $0.append($1)
//            }
//        }.reversed() + [.vertical(card, order)]
    }
    
    public mutating func horizontal(card: Index, column: Int) {
        guard card.column != column else { return }
        add(.horizontal(card, column))
        
//        var card = card
//        edit[edit.count - 1].actions = edit[edit.count - 1].actions.dropLast().reversed().reduce(into: []) {
//            if case let .horizontal(previous, index) = $1, index == card.column {
//                card = previous
//            } else if case let .vertical(previous, index) = $1, previous.column == card.column, index == card.order {
//                card = previous
//            } else {
//                $0.append($1)
//            }
//        }.reversed() + [.horizontal(card, column)]
    }
    
    private mutating func add(_ action: Action) {
        if snaps.isEmpty || Calendar.current.dateComponents([.hour], from: snaps.last!.date, to: .init()).hour! > 0 {
            snaps.append(.init(state: snaps.last?.columns ?? []))
        }
        snaps[snaps.count - 1].add(action)
        snaps[snaps.count - 1].compress(state: snaps.count > 1 ? snaps[snaps.count - 2].columns : [])
    }
    
    public func hash(into: inout Hasher) {
        into.combine(name)
        into.combine(snaps.last!.columns)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.snaps.last!.columns == rhs.snaps.last!.columns
    }
}
