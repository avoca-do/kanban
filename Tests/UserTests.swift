import XCTest
import Combine
@testable import Kanban

final class UserTests: XCTestCase {
    private var user: User!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        user = .init()
        subs = .init()
        Memory.shared = .init()
    }
    
    func testMakeBoard() {
        let expectBoard = expectation(description: "")
        let expectUser = expectation(description: "")
        let date = Date()
        user.date = .distantPast
        
        Memory.shared.save.sink {
            XCTAssertEqual(0, $0.id)
            expectBoard.fulfill()
        }.store(in: &subs)
        
        Memory.shared.update.sink {
            XCTAssertEqual(1, $0.boards.count)
            XCTAssertEqual(1, $0.counter)
            XCTAssertGreaterThanOrEqual($0.date, date)
            expectUser.fulfill()
        }.store(in: &subs)
        
        let board = user.new()
        XCTAssertEqual(board, user.boards.first!.id)
        XCTAssertEqual(1, user.boards.first!.edit.count)
        XCTAssertEqual(1, user.boards.first!.edit.first!.actions.count)
        XCTAssertEqual(.create, user.boards.first!.edit.first!.actions.first!)
        XCTAssertGreaterThanOrEqual(user.boards.first!.edit.first!.date, date)
        XCTAssertGreaterThanOrEqual(user.date, date)
        XCTAssertEqual(1, user.boards.count)
        XCTAssertEqual(1, user.counter)
        XCTAssertEqual(0, board)
        waitForExpectations(timeout: 1)
    }
    
    func testDescriptor() {
        var boardA = Board(id: 0)
        boardA.edit[boardA.edit.count - 1].date = .distantPast
        var boardB = Board(id: 8000)
        boardB.edit[0].date = .distantPast
        boardB.edit.append(.init(actions: [], date: .distantFuture))
        var user = User()
        user.counter = 99
        user.id = "hello world"
        user.boards = [boardB, boardA]
        user.date = .init(timeIntervalSinceNow: 100)
        XCTAssertEqual(user.date, user.descriptor.date)
        XCTAssertEqual(user.id, user.descriptor.id)
        XCTAssertEqual(user.counter, user.descriptor.counter)
        XCTAssertEqual(2, user.descriptor.boards.count)
        XCTAssertEqual(8000, user.descriptor.boards.first?.id)
        XCTAssertEqual(.distantFuture, user.descriptor.boards.first?.date)
        XCTAssertEqual(0, user.descriptor.boards.last?.id)
        XCTAssertEqual(.distantPast, user.descriptor.boards.last?.date)
    }
}
