import XCTest
import Combine
@testable import Kanban

final class BoardTests: XCTestCase {
    private var user: User!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        user = .init()
        subs = .init()
        Memory.shared = .init()
    }
    
    func testRename() {
        let expectBoard = expectation(description: "")
        let expectUser = expectation(description: "")
        let board = user.new()
        
        Memory.shared.save.sink {
            XCTAssertEqual("Pink Floyd", $0.name)
            expectBoard.fulfill()
        }.store(in: &subs)
        
        Memory.shared.update.sink {
            XCTAssertEqual("Pink Floyd", $0.boards.first!.name)
            expectUser.fulfill()
        }.store(in: &subs)
        
        user.rename(board, "Pink Floyd")
        XCTAssertEqual("Pink Floyd", user.boards.first!.name)
        XCTAssertEqual(2, user.boards.first!.actions.count)
        if case let .rename(name) = user.boards.first!.actions.last!.list.first! {
            XCTAssertEqual("Pink Floyd", name)
        } else {
            XCTFail()
        }
        waitForExpectations(timeout: 1)
    }
}
