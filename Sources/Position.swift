import Foundation

public struct Position {
    public let column: Int
    public let index: Int
    
    public init(column: Int, index: Int) {
        self.column = column
        self.index = index
    }
}
