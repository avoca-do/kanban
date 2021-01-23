import Foundation

extension Data {
    func add(_ date: Date) -> Self {
        add(date.timestamp)
    }
    
    func add(_ string: String) -> Self {
        {
            add(UInt16($0.count)) + $0
        } (Data(string.utf8))
    }
    
    func add(_ number: UInt16) -> Self {
        self + Swift.withUnsafeBytes(of: number) {
            .init(bytes: $0.bindMemory(to: UInt8.self).baseAddress!, count: 2)
        }
    }
    
    func add(_ number: UInt32) -> Self {
        self + Swift.withUnsafeBytes(of: number) {
            .init(bytes: $0.bindMemory(to: UInt8.self).baseAddress!, count: 4)
        }
    }
    
    private var compressed: Data? {
        try? (self as NSData).compressed(using: .lzfse) as Data
    }
    
    private var decompressed: Data? {
        try? (self as NSData).decompressed(using: .lzfse) as Data
    }
}
