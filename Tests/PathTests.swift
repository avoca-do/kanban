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
    
    func testChild() {
        XCTAssertEqual(.card(.column(.board(4), 2), 3), Path.column(.board(4), 2).child(index: 3))
        XCTAssertEqual(.column(.board(4), 3), Path.board(4).child(index: 3))
        XCTAssertEqual(.card(.column(.board(4), 2), 3), Path.card(.column(.board(4), 2), 3).child(index: 5))
    }
}
