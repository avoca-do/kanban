import XCTest
@testable import Kanban

final class BoardTests: XCTestCase {
    func testTotal() {
        var board = Board()
        XCTAssertEqual(0, board.total)
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        XCTAssertEqual(1, board.total)
    }
}
