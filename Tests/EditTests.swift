import XCTest
@testable import Kanban

final class EditTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testCreate() {
        XCTAssertEqual(3, board.count)
        XCTAssertEqual("DO", board[0].title)
        XCTAssertEqual("DOING", board[1].title)
        XCTAssertEqual("DONE", board[2].title)
    }
    
    func testGroup() {
        board.card()
        board.card()
        board.card()
        board.card()
        XCTAssertEqual(1, board.edit.count)
        XCTAssertEqual(5, board.edit.first!.actions.count)
    }
    
    func testUpdateDateToLast() {
        let date = Date()
        board.edit[board.edit.count - 1].date = Date(timeIntervalSinceNow: -295)
        board.card()
        XCTAssertEqual(1, board.edit.count)
        XCTAssertEqual(.card, board.edit.first!.actions.last)
        XCTAssertLessThanOrEqual(board.edit.first!.date, date)
    }
    
    func testGroupBy5Minutes() {
        let date = Date()
        board.edit[board.edit.count - 1].date = Date(timeIntervalSinceNow: -301)
        board.card()
        XCTAssertEqual(2, board.edit.count)
        XCTAssertLessThanOrEqual(board.edit.first!.date, date)
        XCTAssertGreaterThanOrEqual(board.edit.last!.date, date)
    }
    
    func testCard() {
        board.card()
        XCTAssertEqual(1, board[0].count)
        board.columns[0].cards[0] = "hello world"
        board.card()
        XCTAssertEqual(2, board[0].count)
        XCTAssertEqual("hello world", board[0][1])
    }
    
    func testContent() {
        board.card()
        board.card()
        board.content(position: .init(column: 0, card: 1), text: "hello world")
        XCTAssertEqual("hello world", board[0][1])
    }
}
