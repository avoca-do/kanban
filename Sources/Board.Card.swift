import Foundation

public extension Board {
    struct Card: Equatable, Archivable {
        public internal(set) var column: Int
        public internal(set) var order: Int
        
        var data: Data {
            Data()
                .add(UInt8(column))
                .add(UInt16(order))
        }
        
        public init(column: Int, order: Int) {
            self.column = column
            self.order = order
        }
        
        init(data: inout Data) {
            column = .init(data.removeFirst())
            order = .init(data.uInt16())
        }
    }
}
