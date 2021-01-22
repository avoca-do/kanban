import Foundation

extension UInt8 {
    var bits: [Bool] {
        (0 ..< 8).map {
            print("index \($0), \((self >> $0).set)")
            return (self >> $0).set
        }
    }
    
    private var set: Bool {
        self & 1 == 1
    }
}
