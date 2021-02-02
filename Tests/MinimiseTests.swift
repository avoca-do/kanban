import XCTest
@testable import Kanban

final class MinimiseTests: XCTestCase {
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
    
    
    func testHorizontal() {
        board.card()
        board[horizontal: 0, 0] = 1
        board[horizontal: 1, 0] = 2
        XCTAssertEqual(1, board[2].count)
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
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
    
    func testVerticalReturns() {
        board.card()
        board.card()
        board[vertical: 0, 0] = 1
        board[vertical: 0, 1] = 0
        XCTAssertEqual(1, board[0][0])
        XCTAssertEqual(3, board.snaps.first!.state.actions.count)
    }
    /*
    func testVertical() {
        board.card()
        board.card()
        board.card()
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "hello world")
        board.vertical(card: .init(column: 0, order: 0), order: 1)
        board.vertical(card: .init(column: 0, order: 1), order: 2)
        board.vertical(card: .init(column: 0, order: 2), order: 3)
        XCTAssertEqual("hello world", board[0][3])
        XCTAssertEqual(7, board.edit.first!.actions.count)
    }
    
    func testHorizontal() {
        board.card()
        board.horizontal(card: .init(column: 0, order: 0), column: 1)
        board.horizontal(card: .init(column: 1, order: 0), column: 2)
        board.horizontal(card: .init(column: 2, order: 0), column: 1)
        XCTAssertTrue(board[0].isEmpty)
        XCTAssertTrue(board[2].isEmpty)
        XCTAssertEqual(1, board[1].count)
        XCTAssertEqual(3, board.edit.first!.actions.count)
    }
    
    func testHorizontalAndVertical() {
        board.card()
        board.card()
        board.card()
        board.card()
        board.card()
        board.card()
        board.horizontal(card: .init(column: 0, order: 0), column: 1)
        board.horizontal(card: .init(column: 0, order: 0), column: 1)
        board.content(card: .init(column: 0, order: 0), text: "hello world")
        board.vertical(card: .init(column: 0, order: 0), order: 1)
        board.vertical(card: .init(column: 0, order: 1), order: 2)
        board.vertical(card: .init(column: 0, order: 2), order: 3)
        board.horizontal(card: .init(column: 0, order: 3), column: 1)
        board.vertical(card: .init(column: 1, order: 0), order: 1)
        board.vertical(card: .init(column: 1, order: 1), order: 2)
        board.horizontal(card: .init(column: 1, order: 2), column: 2)
        XCTAssertEqual("hello world", board[2][0])
        XCTAssertEqual(3, board[0].count)
        XCTAssertEqual(2, board[1].count)
        XCTAssertEqual(1, board[2].count)
        XCTAssertEqual(11, board.edit.first!.actions.count)
        print(board.edit.first!.actions)
    }
    
    func testMixedHorizontal() {
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "a")
        board.horizontal(card: .init(column: 0, order: 0), column: 1)
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "b")
        board.edit[0].date = .init(timestamp: 0)
        board.horizontal(card: .init(column: 0, order: 0), column: 1)
        board.horizontal(card: .init(column: 1, order: 1), column: 2)
        XCTAssertEqual(2, board.edit.last!.actions.count)
        XCTAssertEqual("b", board[1][0])
        XCTAssertEqual("a", board[2][0])
    }
 */
}
