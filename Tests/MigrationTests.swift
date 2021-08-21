import XCTest
import Archivable
@testable import Kanban

final class MigrationTests: XCTestCase {
    func testDateLegacyToNew() {
        var archive = Legacy.new
        archive.capacity = 100
        XCTAssertEqual(100, archive.data.prototype(Archive.self).capacity)
    }
    
    func testDateNewToLegacy() {
        var archive = Archive.new
        archive.capacity = 100
        XCTAssertEqual(100, archive.data.prototype(Legacy.self).capacity)
    }
}

private struct Legacy: Archived {
    public static let new = Self()
    
    public var timestamp: UInt32 {
        get {
            items
                .compactMap(\.snaps.last)
                .map(\.state.date.timestamp)
                .max()
                ?? 0
        }
        set {
            
        }
    }
    
    public internal(set) var capacity = 1
    
    public var data: Data {
        Data()
            .adding(UInt8(items.count))
            .adding(items.flatMap(\.data))
            .adding(UInt16(capacity))
            .compressed
    }
    
    public var items: [Board]
    
    private init() {
        items = []
    }
    
    public init(data: inout Data) {
        data.decompress()
        items = (0 ..< .init(data.removeFirst())).map { _ in
            .init(data: &data)
        }
        capacity = .init(data.uInt16())
    }
}
