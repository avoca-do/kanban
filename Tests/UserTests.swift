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
            XCTAssertEqual("Some", $0.name)
            XCTAssertEqual(0, $0.id)
            expectBoard.fulfill()
        }.store(in: &subs)
        
        Memory.shared.update.sink {
            XCTAssertEqual(1, $0.boards.count)
            XCTAssertEqual(1, $0.counter)
            expectUser.fulfill()
        }.store(in: &subs)
        
        let board = user.board("Some")
        
        XCTAssertEqual(board.id, user.boards.first!.id)
        XCTAssertGreaterThanOrEqual(user.boards.first!.update, .init(date.timeIntervalSince1970))
        XCTAssertEqual(1, user.boards.count)
        XCTAssertEqual(1, user.counter)
        XCTAssertEqual("Some", board.name)
        XCTAssertEqual(0, board.id)
        waitForExpectations(timeout: 1)
    }
}
