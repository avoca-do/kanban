import XCTest
@testable import Kanban

final class BoardTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(board[3])
        XCTAssertNotNil(board[5, 5])
    }
}
