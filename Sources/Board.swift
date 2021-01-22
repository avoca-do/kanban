import Foundation

public struct Board: Identifiable, Hashable {
    public private(set) var name = ""
    public private(set) var columns = [Column]()
    public let id: Int
    private(set) var actions: [Action]
    
    init(id: Int) {
        self.id = id
        actions = [.init(list: [.create], date: .init())]
    }
    
    mutating func add(_ action: Action.Do) {
        actions.append(.init(list: [action], date: .init()))
        
        switch action {
        case let .rename(name):
            self.name = name
        default:
            break
        }
    }
    
    public func hash(into: inout Hasher) {
        into.combine(id)
        into.combine(name)
        into.combine(columns)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.columns == rhs.columns
    }
}
