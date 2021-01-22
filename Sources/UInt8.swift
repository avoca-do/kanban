import Foundation

extension UInt8 {
    var bits: [Bool] {
        (0 ..< 8).map {
            self >> $0
        }.map(\.set)
    }
    
    private var set: Bool {
        self & 1 == 1
    }
}
