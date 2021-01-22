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
        let expect = expectation(description: "")
        
        Memory.shared.save.sink {
            XCTAssertEqual("Some", $0.name)
            XCTAssertEqual(0, $0.id)
            expect.fulfill()
        }.store(in: &subs)
        
        let board = user.board("Some")
        
        XCTAssertTrue(user.boards.first!)
        XCTAssertEqual(1, user.boards.count)
        XCTAssertEqual("Some", board.name)
        XCTAssertEqual(0, board.id)
        waitForExpectations(timeout: 1)
    }
}
