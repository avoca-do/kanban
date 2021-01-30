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
        board.edit[board.edit.count - 1].date = Date(timeIntervalSinceNow: -3599)
        board.card()
        XCTAssertEqual(1, board.edit.count)
        XCTAssertEqual(.card, board.edit.first!.actions.last)
        XCTAssertLessThanOrEqual(board.edit.first!.date, date)
    }
    
    func testGroupBy1Hour() {
        let date = Date()
        board.edit[board.edit.count - 1].date = Date(timeIntervalSinceNow: -3601)
        board.card()
        XCTAssertEqual(2, board.edit.count)
        XCTAssertLessThanOrEqual(board.edit.first!.date, date)
        XCTAssertGreaterThanOrEqual(board.edit.last!.date, date)
    }
    
    func testRename() {
        board.rename("hello ")
        XCTAssertEqual("hello", board.name)
    }
    
    func testRenameEmpty() {
        board.rename(" hello")
        board.rename("\n")
        XCTAssertEqual("hello", board.name)
    }
    
    func testRenameSame() {
        board.rename(" hello")
        board.rename("hello ")
        XCTAssertEqual(2, board.edit.first!.actions.count)
    }
    
    func testCard() {
        board.card()
        XCTAssertEqual(1, board[0].count)
        board.columns[0].cards[0].content = "hello world"
        board.card()
        XCTAssertEqual(2, board[0].count)
        XCTAssertEqual("hello world", board[0][1])
    }
    
    func testContent() {
        board.card()
        board.card()
        board.content(card: .init(column: 0, order: 1), text: " hello world")
        XCTAssertEqual("hello world", board[0][1])
        XCTAssertEqual(4, board.edit.last!.actions.count)
    }
    
    func testContentEmpty() {
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "")
        board.content(card: .init(column: 0, order: 0), text: "\n")
        board.content(card: .init(column: 0, order: 0), text: " ")
        board.content(card: .init(column: 0, order: 0), text: "\t")
        board.content(card: .init(column: 0, order: 0), text: "\n \t\n")
        XCTAssertEqual(2, board.edit.first!.actions.count)
    }
    
    func testContentSame() {
        board.card()
        board.content(card: .init(column: 0, order: 0), text: " hello world")
        board.content(card: .init(column: 0, order: 0), text: "hello world ")
        XCTAssertEqual(3, board.edit.first!.actions.count)
    }
    
    func testVertical() {
        board.card()
        board.columns[0].cards[0].content = "hello world"
        board.card()
        board.vertical(card: .init(column: 0, order: 1), order: 0)
        XCTAssertEqual("hello world", board[0][0])
        XCTAssertEqual(2, board[0].count)
    }
    
    func testVerticalSameOrder() {
        board.card()
        board.card()
        board.vertical(card: .init(column: 0, order: 1), order: 1)
        XCTAssertEqual(3, board.edit.first!.actions.count)
    }
    
    func testHorizontal() {
        board.card()
        board.horizontal(card: .init(column: 0, order: 0), column: 1)
        XCTAssertTrue(board[0].isEmpty)
        XCTAssertEqual(1, board[1].count)
    }
    
    func testHorizontalSameColumn() {
        board.card()
        board.horizontal(card: .init(column: 0, order: 0), column: 0)
        XCTAssertEqual(2, board.edit.first!.actions.count)
    }
}
