import XCTest
@testable import Kanban

final class PathTests: XCTestCase {
    func testBoard() {
        XCTAssertEqual(1, Path.board(1).board)
        XCTAssertEqual(1, Path.column(.board(1), 2).board)
        XCTAssertEqual(1, Path.card(.column(.board(1), 2), 3).board)
    }
    
    func testColumn() {
        XCTAssertEqual(0, Path.board(1).column)
        XCTAssertEqual(2, Path.column(.board(1), 2).column)
        XCTAssertEqual(2, Path.card(.column(.board(1), 2), 3).column)
    }
    
    func testCard() {
        XCTAssertEqual(0, Path.board(1).card)
        XCTAssertEqual(0, Path.column(.board(1), 2).card)
        XCTAssertEqual(3, Path.card(.column(.board(1), 2), 3).card)
    }
}
