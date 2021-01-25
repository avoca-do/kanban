import Foundation

public struct Board: Hashable, Archivable {
    public private(set) var name: String
    public private(set) var columns: [Column]
    var edit: [Edit]
    
    var data: Data {
        Data()
            .add(name)
            .add(UInt16(edit.count))
            .add(edit.flatMap(\.data))
    }
    
    init() {
        name = ""
        columns = []
        edit = [.init(action: .create)]
    }
    
    init(data: inout Data) {
        name = data.string()
        columns = []
        edit = (0 ..< .init(data.uInt16()))
            .map { _ in
                .init(data: &data)
            }
    }
    
    public mutating func card() {
        add(.card)
    }
    
    public mutating func rename(_ name: String) {
        add(.rename(name))
    }
    
    private mutating func add(_ action: Edit.Action) {
        if Calendar.current.dateComponents([.minute], from: edit.last!.date, to: .init()).minute! > 4 {
            edit.append(.init(action: action))
        } else {
            edit[edit.count - 1].actions.append(action)
        }
        
        switch action {
        case let .rename(name):
            self.name = name
        default:
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
