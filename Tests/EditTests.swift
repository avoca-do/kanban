import XCTest
@testable import Kanban

final class EditTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init(id: 0)
    }
    
    func testGroup() {
        board.add(.card)
        board.add(.card)
        board.add(.card)
        board.add(.card)
        XCTAssertEqual(1, board.edit.count)
        XCTAssertEqual(5, board.edit.first!.actions.count)
    }
    
    func testUpdateDateToLast() {
        let date = Date()
        board.edit[board.edit.count - 1].date = Date(timeIntervalSinceNow: -295)
        board.add(.card)
        XCTAssertEqual(1, board.edit.count)
        XCTAssertEqual(.card, board.edit.first!.actions.last)
        XCTAssertLessThanOrEqual(board.edit.first!.date, date)
    }
    
    func testGroupBy5Minutes() {
        let date = Date()
        board.edit[board.edit.count - 1].date = Date(timeIntervalSinceNow: -301)
        board.add(.card)
        XCTAssertEqual(2, board.edit.count)
        XCTAssertLessThanOrEqual(board.edit.first!.date, date)
        XCTAssertGreaterThanOrEqual(board.edit.last!.date, date)
    }
}
