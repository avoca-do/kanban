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
            XCTAssertEqual(board.snaps[$0].columns, board.data.mutating(transform: Board.init(data:)).snaps[$0].columns)
        }
    }
    
    func testContent() {
        board.card()
        board[0, 0] = "hello world"
        board[0, 0] = "total recall"
        board[0, 0] = "lorem ipsum"
        XCTAssertEqual("lorem ipsum", board[0][0])
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testContentRedundant() {
        board.card()
        board[0, 0] = "hello world"
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        board[0, 0] = "total recall"
        board[0, 0] = "lorem ipsum"
        board[0, 0] = "hello world"
        XCTAssertEqual("hello world", board[0][0])
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testHorizontal() {
        board.card()
        board[horizontal: 0, 0] = 1
        board[horizontal: 1, 0] = 2
        XCTAssertEqual(1, board[2].count)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontalRedundant() {
        board.card()
        board[horizontal: 0, 0] = 1
        board[horizontal: 1, 0] = 0
        XCTAssertEqual(0, board[0][0])
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontalRedundantUpdate() {
        board.card()
        board[horizontal: 0, 0] = 1
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        
        board[horizontal: 1, 0] = 0
        board[horizontal: 0, 0] = 1
        XCTAssertEqual(0, board[1][0])
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testVertical() {
        board.card()
        board.card()
        board.card()
        board[vertical: 0, 0] = 1
        board[vertical: 0, 1] = 2
        XCTAssertEqual(2, board[0][2])
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
    
    func testVerticalRedundant() {
        board.card()
        board.card()
        board[vertical: 0, 0] = 1
        board[vertical: 0, 1] = 0
        XCTAssertEqual(1, board[0][0])
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testVerticalRedundantUpdate() {
        board.card()
        board.card()
        board[vertical: 0, 0] = 1
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        
        board[vertical: 0, 1] = 0
        board[vertical: 0, 0] = 1
        XCTAssertEqual(1, board[0][1])
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testVerticalThenHorizontal() {
        board.card()
        board.card()
        board[vertical: 0, 0] = 1
        board[horizontal: 0, 1] = 1
        XCTAssertEqual(1, board[1][0])
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func testMixingIndexes() {
        board.card()
        board.card()
        board[vertical: 0, 0] = 1 // id 1
        board[horizontal: 0, 1] = 1 // id 1
        board[horizontal: 0, 0] = 1 // id 0
        board[vertical: 1, 0] = 1 // id 0
        board[vertical: 1, 0] = 1 // id 1
        board[horizontal: 1, 1] = 2 // id 1
        XCTAssertEqual(1, board[2][0])
        XCTAssertEqual(0, board[1][0])
        XCTAssertEqual(6, board.snaps.first!.state.actions.count)
    }
    
    func test_goingBackToFirst_butNotLastId_vertical() {
        board.card()
        board.card()
        board[vertical: 0, 1] = 0
        XCTAssertEqual(0, board[0][0])
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func test_goingBackToFirst_butNotLastId_horizontal() {
        board.card()
        board.card()
        board[horizontal: 0, 1] = 1
        board[horizontal: 1, 0] = 0
        XCTAssertEqual(0, board[0][0])
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func testTitle() {
        board.title(column: 0, "hello world")
        board.title(column: 0, "lorem ipsum")
        XCTAssertEqual("lorem ipsum", board[0].title)
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testTitleRedundant() {
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        
        board.title(column: 0, "hello world")
        board.title(column: 0, "DO")
        XCTAssertEqual("DO", board[0].title)
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testRemove() {
        board.card()
        board[horizontal: 0, 0] = 1
        board.card()
        board[0, 0] = "hello world"
        board[0, 0] = "total recall"
        board[0, 0] = "lorem ipsum"
        board[horizontal: 0, 0] = 1
        board[vertical: 1, 0] = 1
        board.remove(column: 1, index: 1)
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
}
