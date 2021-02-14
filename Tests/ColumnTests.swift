import XCTest
@testable import Kanban

final class ColumnTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(board[.column(.archive, 0)][.card(.column(.archive, 3), 0)])
    }
}
