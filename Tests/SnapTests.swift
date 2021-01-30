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
        XCTAssertEqual(5, board.snaps.first!.actions.count)
    }
    
    func testUpdateDateToLast() {
        let date = Date()
        var data = Data()
            .add(Date(timeIntervalSinceNow: -3599).timestamp)
            .add(UInt8(board.snaps[0].actions.count))
            .add(board.snaps[0].actions.flatMap(\.data))
        board.snaps[0] = .init(data: &data)
        board.card()
        XCTAssertEqual(1, board.snaps.count)
        XCTAssertEqual(.card, board.snaps.first!.actions.last)
        XCTAssertGreaterThanOrEqual(board.snaps.first!.date, date)
    }
    
    func testGroupBy1Hour() {
        let date = Date()
        var data = Data()
            .add(Date(timeIntervalSinceNow: -3601).timestamp)
            .add(UInt8(board.snaps[0].actions.count))
            .add(board.snaps[0].actions.flatMap(\.data))
        board.snaps[0] = .init(data: &data)
        board.card()
        XCTAssertEqual(2, board.snaps.count)
        XCTAssertLessThanOrEqual(board.snaps.first!.date, date)
        XCTAssertGreaterThanOrEqual(board.snaps.last!.date, date)
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
        XCTAssertEqual(4, board.snaps.last!.actions.count)
    }
    
    func testContentEmpty() {
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "")
        board.content(card: .init(column: 0, order: 0), text: "\n")
        board.content(card: .init(column: 0, order: 0), text: " ")
        board.content(card: .init(column: 0, order: 0), text: "\t")
        board.content(card: .init(column: 0, order: 0), text: "\n \t\n")
        XCTAssertEqual(2, board.snaps.first!.actions.count)
    }
    
    func testContentSame() {
        board.card()
        board.content(card: .init(column: 0, order: 0), text: " hello world")
        board.content(card: .init(column: 0, order: 0), text: "hello world ")
        XCTAssertEqual(3, board.snaps.first!.actions.count)
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
        XCTAssertEqual(3, board.snaps.first!.actions.count)
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
        XCTAssertEqual(2, board.snaps.first!.actions.count)
    }
}
