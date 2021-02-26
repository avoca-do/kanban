import XCTest
import Combine
@testable import Kanban

final class CapacityMigrationTests: XCTestCase {
    private var archive: Archive!
    
    override func setUp() {
        Memory.shared = .init()
        Memory.shared.subs = .init()
    }
    
    func testArchiving() {
        var archive = Archive()
        archive.boards = [.init()]
        var data = archive.data
        data.decompress()
        data.removeLast(2)
        XCTAssertEqual(1, data.compressed.mutating(transform: Archive.init(data:)).boards.count)
    }
}
