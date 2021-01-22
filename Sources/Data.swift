import Foundation

extension Data {
    init(user: User) {
        self.init()
        append(UInt8())
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
