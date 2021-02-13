import XCTest
@testable import Kanban

final class BoardTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testCount() {
        XCTAssertEqual(0, board[.column(.empty, 0)])
    }
    
    func testEmpty() {
        XCTAssertEqual(true, board[.column(.empty, 0)])
    }
    
    func testIndexOutOfBounds() {
        XCTAssertEqual(true, board[.column(.empty, 3)])
        XCTAssertEqual(0, board[.column(.empty, 3)])
    }
}
