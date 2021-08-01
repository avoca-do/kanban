import XCTest
@testable import Kanban

final class FilterTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    override func tearDown() {
        XCTAssertEqual(board, board.data.mutating(transform: Board.init(data:)))
        XCTAssertEqual(board.snaps.count, board.data.mutating(transform: Board.init(data:)).snaps.count)
        (0 ..< board.snaps.count).forEach {
            XCTAssertEqual(board.snaps[$0].items, board.data.mutating(transform: Board.init(data:)).snaps[$0].items)
        }
    }
    
    func testContent() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "hello world")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "total recall")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "lorem ipsum")))
        XCTAssertEqual("lorem ipsum", board[0][0].content)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testContentRedundant() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "hello world")))
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board = board
            .with(snaps: [.init(data: &data, after: nil)])
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "total recall")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "lorem ipsum")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "hello world")))
        XCTAssertEqual("hello world", board[0][0].content)
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testHorizontal() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
//        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
//        board.move(.card(.column(.archive, 1), 0), horizontal: 2)
        XCTAssertEqual(1, board[2].count)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontalRedundant() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
//        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
//        board.move(.card(.column(.archive, 1), 0), horizontal: 0)
        XCTAssertEqual(0, board[0][0].id)
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontalRedundantButUpdateDate() {
        let date = Date()
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
        
        var data = Data()
            .adding(Date(timeIntervalSinceNow: -100).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board = board.with(snaps: [.init(data: &data, after: nil)])
        board.move(.card(.column(.archive, 1), 0), horizontal: 0)
        XCTAssertGreaterThanOrEqual(board.snaps[0].state.date.timeIntervalSince1970, date.timeIntervalSince1970)
    }
    
    func testHorizontalRedundantUpdate() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board = board.with(snaps: [.init(data: &data, after: nil)])
        
        board.move(.card(.column(.archive, 1), 0), horizontal: 0)
        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
        XCTAssertEqual(0, board[1][0].id)
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testVertical() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), vertical: 1)
        board.move(.card(.column(.archive, 0), 1), vertical: 2)
        XCTAssertEqual(2, board[0][2].id)
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
    
    func testVerticalRedundant() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), vertical: 1)
        board.move(.card(.column(.archive, 0), 1), vertical: 0)
        XCTAssertEqual(1, board[0][1].id)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testVerticalRedundantUpdate() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), vertical: 1)
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board = board.with(snaps: [.init(data: &data, after: nil)])
        
        board.move(.card(.column(.archive, 0), 1), vertical: 0)
        board.move(.card(.column(.archive, 0), 0), vertical: 1)
        XCTAssertEqual(1, board[0][1].id)
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testVerticalThenHorizontal() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), vertical: 1)
        board.move(.card(.column(.archive, 0), 1), horizontal: 1)
        XCTAssertEqual(1, board[1][0].id)
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func testMixingIndexes() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), vertical: 1) // id 1
        board.move(.card(.column(.archive, 0), 1), horizontal: 1) // id 1
        board.move(.card(.column(.archive, 0), 0), horizontal: 1) // id 0
        board.move(.card(.column(.archive, 1), 0), vertical: 1) // id 0
        board.move(.card(.column(.archive, 1), 0), vertical: 1) // id 1
        board.move(.card(.column(.archive, 1), 1), horizontal: 2) // id 1
        XCTAssertEqual(1, board[2][0].id)
        XCTAssertEqual(0, board[1][0].id)
        XCTAssertEqual(6, board.snaps.first!.state.actions.count)
    }
    
    func test_goingBackToFirst_butNotLastId_vertical() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 1), vertical: 0)
        XCTAssertEqual(0, board[0][0].id)
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func test_goingBackToFirst_butNotLastId_horizontal() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 1), horizontal: 1)
        board.move(.card(.column(.archive, 1), 0), horizontal: 0)
        XCTAssertEqual(0, board[0][0].id)
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func testTitle() {
        board = board
            .with(snaps: board
                    .snaps
                    .adding(action: .name(0, "hello world")))
        board = board
            .with(snaps: board
                    .snaps
                    .adding(action: .name(0, "lorem ipsum")))
        XCTAssertEqual("lorem ipsum", board[0].name)
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testTitleRedundant() {
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board = board
            .with(snaps: [.init(data: &data, after: nil)])
        board = board
            .with(snaps: board
                    .snaps
                    .adding(action: .name(0, "hello world")))
        board = board
            .with(snaps: board
                    .snaps
                    .adding(action: .name(0, "DO")))
        XCTAssertEqual("DO", board[0].name)
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testRemove() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board
            .with(snaps: board
                    .snaps
                    .adding(action: .name(0, "hello world")))
        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
        board.move(.card(.column(.archive, 1), 0), vertical: 1)
        board.remove(.card(.column(.archive, 1), 1))
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
    
    func testDrop() {
        board = board
            .with(snaps: board
                    .snaps
                    .adding(action: .name(0, "Total recall")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(1, "hello world")))
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .content(0, "lorem ipsum")))
        board.move(.card(.column(.archive, 0), 0), vertical: 1)
        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
        board.drop(.column(.archive, 0))
        XCTAssertEqual(6, board.snaps.first!.state.actions.count)
    }
    
    func testDropHorizontal() {
        board = board.with(snaps: board
                                .snaps
                                .adding(action: .card))
        board.move(.card(.column(.archive, 0), 0), horizontal: 1)
        board.drop(.column(.archive, 1))
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
}
