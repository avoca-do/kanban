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
        
        Memory.shared.save.sink {
            XCTAssertEqual(0, $0.id)
            expectBoard.fulfill()
        }.store(in: &subs)
        
        Memory.shared.update.sink {
            XCTAssertEqual(1, $0.boards.count)
            XCTAssertEqual(1, $0.counter)
            expectUser.fulfill()
        }.store(in: &subs)
        
        let board = user.new()
        XCTAssertEqual(board, user.boards.first!.id)
        XCTAssertEqual(1, user.boards.first!.actions.count)
        XCTAssertEqual(1, user.boards.first!.actions.first!.list.count)
        XCTAssertEqual(.create, user.boards.first!.actions.first!.list.first!)
        XCTAssertGreaterThanOrEqual(user.boards.first!.actions.first!.date, date)
        XCTAssertEqual(1, user.boards.count)
        XCTAssertEqual(1, user.counter)
        XCTAssertEqual(0, board)
        waitForExpectations(timeout: 1)
    }
}
