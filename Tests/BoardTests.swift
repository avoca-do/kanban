import XCTest
@testable import Kanban

final class BoardTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(board[.column(.empty, 3)])
    }
}
