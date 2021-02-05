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
        XCTAssertEqual(1, board.snaps.count)
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
    
    func testUpdateDateToLast() {
        let date = Date()
        var data = Data()
            .adding(Date(timeIntervalSinceNow: -3599).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        board.card()
        XCTAssertEqual(1, board.snaps.count)
        XCTAssertEqual(.card, board.snaps.first!.state.actions.last)
        XCTAssertGreaterThanOrEqual(board.snaps.first!.state.date, date)
    }
    
    func testGroupBy1Hour() {
        let date = Date()
        var data = Data()
            .adding(Date(timeIntervalSinceNow: -3601).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        board.card()
        XCTAssertEqual(2, board.snaps.count)
        XCTAssertLessThanOrEqual(board.snaps.first!.state.date, date)
        XCTAssertGreaterThanOrEqual(board.snaps.last!.state.date, date)
    }
    
    func testCard() {
        board.card()
        XCTAssertEqual(1, board[0].count)
        board[0, 0] = "hello world"
        board.card()
        XCTAssertEqual(2, board[0].count)
        XCTAssertEqual("hello world", board[0][1])
    }
    
    func testRemove() {
        board.card()
        board.remove(column: 0, index: 0)
        XCTAssertTrue(board[0].isEmpty)
    }
    
    func testDrop() {
        board.drop(column: 1)
        XCTAssertEqual(2, board.count)
    }
    
    func testContent() {
        board.card()
        board.card()
        board[0, 1] = " hello world"
        XCTAssertEqual("hello world", board[0][1])
        XCTAssertEqual(4, board.snaps.last!.state.actions.count)
    }
    
    func testContentEmpty() {
        board.card()
        board[0, 0] = ""
        board[0, 0] = "\n"
        board[0, 0] = " "
        board[0, 0] = "\t"
        board[0, 0] = "\n \t\n"
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testContentSame() {
        board.card()
        board[0, 0] = " hello world"
        board[0, 0] = "hello world "
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testVertical() {
        board.card()
        board[0, 0] = "hello world"
        board.card()
        board[vertical: 0, 1] = 0
        XCTAssertEqual("hello world", board[0][0])
        XCTAssertEqual(2, board[0].count)
    }
    
    func testVerticalSameIndex() {
        board.card()
        board.card()
        board[vertical: 0, 1] = 1
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontal() {
        board.card()
        board[horizontal: 0, 0] = 1
        XCTAssertTrue(board[0].isEmpty)
        XCTAssertEqual(1, board[1].count)
    }
    
    func testHorizontalSameColumn() {
        board.card()
        board[horizontal: 0, 0] = 0
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testTitle() {
        board.title(column: 0, " Lorem Ipsum\n")
        XCTAssertEqual("Lorem Ipsum", board[0].title)
    }
    
    func testEmpty() {
        board.title(column: 0, " ")
        XCTAssertEqual("DO", board[0].title)
        XCTAssertEqual(1, board.snaps.first!.state.actions.count)
    }
    
    func testSame() {
        board.title(column: 0, "DO")
        XCTAssertEqual("DO", board[0].title)
        XCTAssertEqual(1, board.snaps.first!.state.actions.count)
    }
}
