import XCTest
@testable import Kanban

final class CompressTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    override func tearDown() {
        XCTAssertEqual(board, board.data.mutating(transform: Board.init(data:)))
        XCTAssertEqual(board.snaps, board.data.mutating(transform: Board.init(data:)).snaps)
    }
    
    func testContent() {
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "hello world")
        board.content(card: .init(column: 0, order: 0), text: "lorem ipsum")
        XCTAssertEqual("lorem ipsum", board[0][0])
        XCTAssertEqual(3, board.snaps.first!.actions.count)
    }
    
    /*
    func testContentHorizontal() {
        board.card()
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "a")
        board.horizontal(card: .init(column: 0, order: 0), column: 1)
        board.content(card: .init(column: 0, order: 0), text: "b")
    }
    
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
