import XCTest
@testable import Kanban

final class MergeTests: XCTestCase {
    private var board: Board!
    
    override func setUp() {
        board = .init()
    }
    
    override func tearDown() {
        XCTAssertEqual(board, board.data.mutating(transform: Board.init(data:)))
        XCTAssertEqual(board.edit, board.data.mutating(transform: Board.init(data:)).edit)
    }
    
    func testContent() {
        board.card()
        board.content(card: .init(column: 0, order: 0), text: "hello world")
        board.content(card: .init(column: 0, order: 0), text: "lorem ipsum")
        XCTAssertEqual("lorem ipsum", board[0][0])
        XCTAssertEqual(3, board.edit.first!.actions.count)
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
}
