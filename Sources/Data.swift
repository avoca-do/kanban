import Foundation

extension Data {
    var string: String {
        .init(decoding: subdata(in: 2 ..< 2 + .init(
                                    withUnsafeBytes {
                                        $0.baseAddress!.bindMemory(to: UInt16.self, capacity: 1)[0]
                                    })), as: UTF8.self)
    }
    
    func add(_ date: Date) -> Self {
        add(date.timestamp)
    }
    
    func add(_ string: String) -> Self {
        {
            add(UInt16($0.count)) + $0
        } (Data(string.utf8))
    }
    
    func add(_ number: UInt8) -> Self {
        self + [number]
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
    
    private var compressed: Self {
        try! (self as NSData).compressed(using: .lzfse) as Self
    }
    
    private var decompressed: Self {
        try! (self as NSData).decompressed(using: .lzfse) as Self
    }
}
