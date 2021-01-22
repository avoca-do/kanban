import Foundation

extension Data {
    init(user: User) {
        self.init()
        append(UInt8())
    }
    
    var bits: [Bool] {
        flatMap {
            $0.bits
        }
    }
    
    func add(_ bits: [Bool]) -> Self {
        self + bits.enumerated().reduce(into: [UInt8]()) {
            if $1.0 % 8 == 0 {
                $0.append(.init())
            }
            if $1.1 {
                print("add \(($1.0 % 8 < 5 ? 1 : 127))")
                $0[$0.count - 1] |= (($1.0 % 8 < 5 ? 1 : 127) << $1.0 % 8)
            }
        }
    }
    
    private var compressed: Data? {
        try? (self as NSData).compressed(using: .lzfse) as Data
    }
    
    private var decompressed: Data? {
        try? (self as NSData).decompressed(using: .lzfse) as Data
    }
}
