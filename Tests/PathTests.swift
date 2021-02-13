import XCTest
@testable import Kanban

final class PathTests: XCTestCase {
    func testUp() {
        XCTAssertEqual(.empty, Path.empty.up)
        XCTAssertEqual(.empty, Path.board(1).up)
        XCTAssertEqual(.board(1), Path.column(.board(1), 2).up)
        XCTAssertEqual(.column(.board(1), 2), Path.card(.column(.board(1), 2), 3).up)
    }
    
    func testDown() {
        XCTAssertEqual(.board(1), Path.empty.down(1))
        XCTAssertEqual(.column(.board(1), 2), Path.board(1).down(2))
        XCTAssertEqual(.card(.column(.board(1), 2), 3), Path.column(.board(1), 2).down(3))
        XCTAssertEqual(.card(.column(.board(1), 2), 3), Path.card(.column(.board(1), 2), 3))
    }
}
