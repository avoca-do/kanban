import XCTest
@testable import Kanban

final class ColumnTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(board[.column(.empty, 0)][.card(.column(.empty, 3), 0)])
    }
}
