import XCTest
@testable import Kanban

final class EditTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    func testCreate() {
        XCTAssertEqual(3, board.count)
        XCTAssertEqual("DO", board[0].name)
        XCTAssertEqual("DOING", board[1].name)
        XCTAssertEqual("DONE", board[2].name)
    }
    
    func testGroup() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        
        XCTAssertEqual(1, board.snaps.count)
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
    
    func testUpdateDateToLast() {
        let date = Date()
        var data = Data()
            .adding(Date(timeIntervalSinceNow: -3599).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board = board.with(snaps: [.init(data: &data, after: nil)])
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
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
        board = board.with(snaps: [.init(data: &data, after: nil)])
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        XCTAssertEqual(2, board.snaps.count)
        XCTAssertLessThanOrEqual(board.snaps.first!.state.date, date)
        XCTAssertGreaterThanOrEqual(board.snaps.last!.state.date, date)
    }
    
    func testUpdateDateToLastIfEmpty() {
        let date = Date()
        var data0 = Data()
            .adding(Date(timeIntervalSinceNow: -7202).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        var data1 = Data()
            .adding(Date(timeIntervalSinceNow: -3601).timestamp)
            .adding(UInt8(0))
        board = board.with(snaps: [.init(data: &data0, after: nil)])
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: [board.snaps[0], .init(data: &data1, after: board.snaps[0])])
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        XCTAssertEqual(2, board.snaps.count)
        XCTAssertLessThanOrEqual(board.snaps.first!.state.date, date)
        XCTAssertGreaterThanOrEqual(board.snaps.last!.state.date, date)
    }
    
    func testColumn() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .column))
        XCTAssertEqual(4, board.count)
        XCTAssertEqual("", board[3].name)
    }
    
    func testCard() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        XCTAssertEqual(1, board[0].count)
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "hello world")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        XCTAssertEqual(2, board[0].count)
        XCTAssertEqual("hello world", board[0][1].content)
    }
    
    func testRemove() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.remove(.card(.column(.archive, 0), 0))
        XCTAssertTrue(board[0].isEmpty)
    }
    
    func testDrop() {
        board.drop(.column(.archive, 1))
        XCTAssertEqual(2, board.count)
    }
    
    func testContentEmpty() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "\n")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "\r\n")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "\n\r")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, " ")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "\t")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "\n \t\n")))
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
        XCTAssertTrue(board[0][0].content.isEmpty)
    }
    
    func testContentSame() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, " hello world")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "hello world ")))
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testVertical() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "hello world")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .vertical(0, 0)))
        XCTAssertEqual("hello world", board[0][0].content)
        XCTAssertEqual(2, board[0].count)
    }
    
    func testHorizontal() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .horizontal(0, 1)))
        XCTAssertTrue(board[0].isEmpty)
        XCTAssertEqual(1, board[1].count)
    }
    
    func testColumnName() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .name(0, "Lorem ipsum ")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .name(0, "\n")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .name(0, "Lorem ipsum")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .name(0, " Lorem ipsum")))
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
        XCTAssertEqual("Lorem ipsum", board[0].name)
    }
}
