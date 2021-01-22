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
            guard $1.1 else { return }
            $0[$0.count - 1] += 1 << ($1.0 % 8)
        }
    }
    
    func add(_ string: String) -> Self {
        self + {
            Swift.withUnsafeBytes(of: UInt16($0.count)) {
                .init(bytes: $0.bindMemory(to: UInt8.self).baseAddress!, count: 2)
            } + $0
        } (Data(string.utf8))
    }
    
    private var compressed: Data? {
        try? (self as NSData).compressed(using: .lzfse) as Data
    }
    
    private var decompressed: Data? {
        try? (self as NSData).decompressed(using: .lzfse) as Data
    }
}
