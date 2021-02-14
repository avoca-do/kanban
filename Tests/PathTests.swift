import XCTest
@testable import Kanban

final class PathTests: XCTestCase {
    func testUp() {
        XCTAssertEqual(.archive, Path.archive.up)
        XCTAssertEqual(.archive, Path.board(1).up)
        XCTAssertEqual(.board(1), Path.column(.board(1), 2).up)
        XCTAssertEqual(.column(.board(1), 2), Path.card(.column(.board(1), 2), 3).up)
    }
    
    func testDown() {
        XCTAssertEqual(.board(1), Path.archive.down(1))
        XCTAssertEqual(.column(.board(1), 2), Path.board(1).down(2))
        XCTAssertEqual(.card(.column(.board(1), 2), 3), Path.column(.board(1), 2).down(3))
        XCTAssertEqual(.card(.column(.board(1), 2), 3), Path.card(.column(.board(1), 2), 3))
    }
    
    func testBoard() {
        XCTAssertEqual(0, Path.archive.board)
        XCTAssertEqual(1, Path.board(1).board)
        XCTAssertEqual(1, Path.column(.board(1), 2).board)
        XCTAssertEqual(1, Path.card(.column(.board(1), 2), 3).board)
    }
    
    func testColumn() {
        XCTAssertEqual(0, Path.archive.column)
        XCTAssertEqual(0, Path.board(1).column)
        XCTAssertEqual(2, Path.column(.board(1), 2).column)
        XCTAssertEqual(2, Path.card(.column(.board(1), 2), 3).column)
    }
    
    func testCard() {
        XCTAssertEqual(0, Path.archive.card)
        XCTAssertEqual(0, Path.board(1).card)
        XCTAssertEqual(0, Path.column(.board(1), 2).card)
        XCTAssertEqual(3, Path.card(.column(.board(1), 2), 3).card)
    }
}
