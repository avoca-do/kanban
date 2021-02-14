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
        board[content: .card(.column(.empty, 0), 0)] = "hello world"
        board[content: .card(.column(.empty, 0), 0)] = "total recall"
        board[content: .card(.column(.empty, 0), 0)] = "lorem ipsum"
        XCTAssertEqual("lorem ipsum", board[content: .card(.column(.empty, 0), 0)])
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testContentRedundant() {
        board.card()
        board[content: .card(.column(.empty, 0), 0)] = "hello world"
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        board[content: .card(.column(.empty, 0), 0)] = "total recall"
        board[content: .card(.column(.empty, 0), 0)] = "lorem ipsum"
        board[content: .card(.column(.empty, 0), 0)] = "hello world"
        XCTAssertEqual("hello world", board[content: .card(.column(.empty, 0), 0)])
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testHorizontal() {
        board.card()
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        board.move(.card(.column(.empty, 1), 0), horizontal: 2)
        XCTAssertEqual(1, board[.column(.empty, 2)].count)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontalRedundant() {
        board.card()
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        board.move(.card(.column(.empty, 1), 0), horizontal: 0)
        XCTAssertEqual(0, board[.card(.column(.empty, 0), 0)][.card(.column(.empty, 0), 0)].id)
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testHorizontalRedundantUpdate() {
        board.card()
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        
        board.move(.card(.column(.empty, 1), 0), horizontal: 0)
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        XCTAssertEqual(0, board[.card(.column(.empty, 1), 0)][.card(.column(.empty, 1), 0)].id)
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testVertical() {
        board.card()
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 0), vertical: 1)
        board.move(.card(.column(.empty, 0), 1), vertical: 2)
        XCTAssertEqual(2, board[.card(.column(.empty, 0), 2)][.card(.column(.empty, 0), 2)].id)
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
    
    func testVerticalRedundant() {
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 0), vertical: 1)
        board.move(.card(.column(.empty, 0), 1), vertical: 0)
        XCTAssertEqual(1, board[.card(.column(.empty, 0), 0)][.card(.column(.empty, 0), 0)].id)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    
    func testVerticalRedundantUpdate() {
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 0), vertical: 1)
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        
        board.move(.card(.column(.empty, 0), 1), vertical: 0)
        board.move(.card(.column(.empty, 0), 0), vertical: 1)
        XCTAssertEqual(1, board[.card(.column(.empty, 0), 1)][.card(.column(.empty, 0), 1)].id)
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testVerticalThenHorizontal() {
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 0), vertical: 1)
        board.move(.card(.column(.empty, 0), 1), horizontal: 1)
        XCTAssertEqual(1, board[.card(.column(.empty, 1), 0)][.card(.column(.empty, 1), 0)].id)
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func testMixingIndexes() {
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 0), vertical: 1) // id 1
        board.move(.card(.column(.empty, 0), 1), horizontal: 1) // id 1
        board.move(.card(.column(.empty, 0), 0), horizontal: 1) // id 0
        board.move(.card(.column(.empty, 1), 0), vertical: 1) // id 0
        board.move(.card(.column(.empty, 1), 0), vertical: 1) // id 1
        board.move(.card(.column(.empty, 1), 1), horizontal: 2) // id 1
        XCTAssertEqual(1, board[.card(.column(.empty, 2), 0)][.card(.column(.empty, 2), 0)].id)
        XCTAssertEqual(0, board[.card(.column(.empty, 1), 0)][.card(.column(.empty, 1), 0)].id)
        XCTAssertEqual(6, board.snaps.first!.state.actions.count)
    }
    
    func test_goingBackToFirst_butNotLastId_vertical() {
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 1), vertical: 0)
        XCTAssertEqual(0, board[.card(.column(.empty, 0), 0)][.card(.column(.empty, 0), 0)].id)
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func test_goingBackToFirst_butNotLastId_horizontal() {
        board.card()
        board.card()
        board.move(.card(.column(.empty, 0), 1), horizontal: 1)
        board.move(.card(.column(.empty, 1), 0), horizontal: 0)
        XCTAssertEqual(0, board[.card(.column(.empty, 0), 0)][.card(.column(.empty, 0), 0)].id)
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
    
    func testTitle() {
        board[title: .column(.empty, 0)] = "hello world"
        board[title: .column(.empty, 0)] = "lorem ipsum"
        XCTAssertEqual("lorem ipsum", board[title: .column(.empty, 0)])
        XCTAssertEqual(2, board.snaps.first!.state.actions.count)
    }
    
    func testTitleRedundant() {
        var data = Data()
            .adding(Date(timeIntervalSince1970: 300).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board.snaps[0] = Board.Snap(data: &data, after: nil)
        
        board[title: .column(.empty, 0)] = "hello world"
        board[title: .column(.empty, 0)] = "DO"
        XCTAssertEqual("DO", board[title: .column(.empty, 0)])
        XCTAssertTrue(board.snaps.last!.state.actions.isEmpty)
    }
    
    func testRemove() {
        board.card()
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        board.card()
        board[content: .card(.column(.empty, 0), 0)] = "hello world"
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        board.move(.card(.column(.empty, 1), 0), vertical: 1)
        board.remove(.card(.column(.empty, 1), 1))
        XCTAssertEqual(5, board.snaps.first!.state.actions.count)
    }
    
    func testDrop() {
        board[title: .column(.empty, 0)] = "Total recall"
        board.card()
        board.card()
        board[content: .card(.column(.empty, 0), 0)] = "hello world"
        board[content: .card(.column(.empty, 0), 1)] = "lorem ipsum"
        board.move(.card(.column(.empty, 0), 0), vertical: 1)
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        board.drop(.column(.empty, 0))
        XCTAssertEqual(6, board.snaps.first!.state.actions.count)
    }
    
    func testDropHorizontal() {
        board.card()
        board.move(.card(.column(.empty, 0), 0), horizontal: 1)
        board.drop(.column(.empty, 1))
        XCTAssertEqual(4, board.snaps.first!.state.actions.count)
    }
}
