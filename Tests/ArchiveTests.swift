import XCTest
import Archivable
@testable import Kanban

final class ArchiveTests: XCTestCase {    
    func testComparison() {
        var archiveA = Archive.new
        let archiveB = Archive.new
        XCTAssertEqual(archiveA, archiveB)
        archiveA.capacity = 2
        XCTAssertNotEqual(archiveA, archiveB)
        XCTAssertGreaterThan(archiveA, archiveB)
    }
    
    func testColumn() {
        var archive = Archive.new
        archive.items = [.init()]
        XCTAssertTrue(archive.isEmpty(.column(.board(0), 0)))
        archive.items[0].card()
        XCTAssertFalse(archive.isEmpty(.column(.board(0), 0)))
    }
}
