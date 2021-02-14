import XCTest
@testable import Kanban

final class EditTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testCreate() {
        XCTAssertEqual(3, board.count)
        XCTAssertEqual("DO", board[.column(.empty, 0)].title)
        XCTAssertEqual("DOING", board[.column(.empty, 1)].title)
        XCTAssertEqual("DONE", board[.column(.empty, 2)].title)
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
    
    func testColumn() {
        board.column()
        XCTAssertEqual(4, board.count)
        XCTAssertEqual("", board[.column(.empty, 3)].title)
    }
    
    func testCard() {
        board.card()
        XCTAssertEqual(1, board[.column(.empty, 0)].count)
        board[content: .card(.column(.empty, 0), 0)] = "hello world"
        board.card()
        XCTAssertEqual(2, board[.column(.empty, 0)].count)
        XCTAssertEqual("hello world", board[content: .card(.column(.empty, 0), 1)])
    }
    
    func testRemove() {
        board.card()
        board.remove(.card(.column(.empty, 0), 0))
        XCTAssertTrue(board[.column(.empty, 0)].isEmpty)
    }
    
    func testDrop() {
        board.drop(.column(.empty, 1))
        XCTAssertEqual(2, board.count)
    }
    
    func testContent() {
        board.card()
        board.card()
        board[content: .card(.column(.empty, 0), 1)] = " hello world"
        XCTAssertEqual("hello world", board[content: .card(.column(.empty, 0), 1)])
        XCTAssertEqual(4, board.snaps.last!.state.actions.count)
    }
    
    func testContentEmpty() {
        board.card()
        board[content: .card(.column(.empty, 0), 0)] = ""
        board[content: .card(.column(.empty, 0), 0)] = "\n"
        board[content: .card(.column(.empty, 0), 0)] = " "
        board[content: .card(.column(.empty, 0), 0)] = "\t"
        board[content: .card(.column(.empty, 0), 0)] = "\n \t\n"
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testContentSame() {
        board.card()
        board[content: .card(.column(.empty, 0), 0)] = " hello world"
        board[content: .card(.column(.empty, 0), 0)] = "hello world "
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testVertical() {
        board.card()
        board[content: .card(.column(.empty, 0), 0)] = "hello world"
        board.card()
        board.move(.card(.column(.empty, 0), 1), vertical: 0)
        XCTAssertEqual("hello world", board[content: .card(.column(.empty, 0), 0)])
        XCTAssertEqual(2, board[.column(.empty, 0)].count)
    }
    
    func testVerticalSameIndex() {
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 1), vertical: 1)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontal() {
        board.card()
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        XCTAssertTrue(board[.column(.empty, 0)].isEmpty)
        XCTAssertEqual(1, board[.column(.empty, 1)].count)
    }
    
    func testHorizontalSameColumn() {
        board.card()
        board.move(.card(.column(.empty, 0), 0), horizontal: 0)
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testTitle() {
        board[title: .column(.empty, 0)] = " Lorem Ipsum\n"
        XCTAssertEqual("Lorem Ipsum", board[.column(.empty, 0)].title)
    }
    
    func testEmpty() {
        board[title: .column(.empty, 0)] = " "
        XCTAssertEqual("DO", board[title: .column(.empty, 0)])
        XCTAssertEqual(1, board.snaps.first!.state.actions.count)
    }
    
    func testSame() {
        board[title: .column(.empty, 0)] = "DO"
        XCTAssertEqual("DO", board[title: .column(.empty, 0)])
        XCTAssertEqual(1, board.snaps.first!.state.actions.count)
    }
}
