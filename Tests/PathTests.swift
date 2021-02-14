import XCTest
@testable import Kanban

final class PathTests: XCTestCase {
    func test_Board() {
        XCTAssertEqual(0, Path.archive._board)
        XCTAssertEqual(1, Path.board(1)._board)
        XCTAssertEqual(1, Path.column(.board(1), 2)._board)
        XCTAssertEqual(1, Path.card(.column(.board(1), 2), 3)._board)
    }
    
    func testBoard() {
        XCTAssertEqual(.archive, Path.archive.board)
        XCTAssertEqual(.board(1), Path.board(1).board)
        XCTAssertEqual(.board(1), Path.column(.board(1), 2).board)
        XCTAssertEqual(.board(1), Path.card(.column(.board(1), 2), 3).board)
    }
    
    func test_Column() {
        XCTAssertEqual(.archive, Path.archive.column)
        XCTAssertEqual(.archive, Path.board(1).column)
        XCTAssertEqual(.column(.board(1), 2), Path.column(.board(1), 2).column)
        XCTAssertEqual(.column(.board(1), 2), Path.card(.column(.board(1), 2), 3).column)
    }
    
    func test_Card() {
        XCTAssertEqual(.archive, Path.archive.card)
        XCTAssertEqual(.archive, Path.board(1).card)
        XCTAssertEqual(.archive, Path.column(.board(1), 2).card)
        XCTAssertEqual(.card(.column(.board(1), 2), 3), Path.card(.column(.board(1), 2), 3).card)
    }
}
