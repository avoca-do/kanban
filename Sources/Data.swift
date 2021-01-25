import Foundation

extension Data {
    var compressed: Self {
        try! (self as NSData).compressed(using: .lzfse) as Self
    }
    
    var decompressed: Self {
        try! (self as NSData).decompressed(using: .lzfse) as Self
    }
    
    mutating func string() -> String {
        let size = Int(uInt16())
        let result = String(decoding: subdata(in: 0 ..< size), as: UTF8.self)
        self = remove(size)
        return result
    }
    
    mutating func uInt16() -> UInt16 {
        let result = withUnsafeBytes {
            $0.baseAddress!.bindMemory(to: UInt16.self, capacity: 1)[0]
        }
        self = remove(2)
        return result
    }
    
    mutating func uInt32() -> UInt32 {
        let result = withUnsafeBytes {
            $0.baseAddress!.bindMemory(to: UInt32.self, capacity: 1)[0]
        }
        self = remove(4)
        return result
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
    
    private mutating func remove(_ amount: Int) -> Self {
        count > amount ? advanced(by: amount) : .init()
    }
}
