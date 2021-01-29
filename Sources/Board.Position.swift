import Foundation

public extension Board {
    struct Position: Equatable, Archivable {
        public let column: Int
        public let card: Int
        
        var data: Data {
            Data()
                .add(UInt8(column))
                .add(UInt16(card))
        }
        
        public init(column: Int, card: Int) {
            self.column = column
            self.card = card
        }
        
        init(data: inout Data) {
            column = .init(data.removeFirst())
            card = .init(data.uInt16())
        }
    }
}
