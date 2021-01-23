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
        let date = Date()
        let board = user.new()
        user.date = .distantPast
        
        Memory.shared.save.sink {
            XCTAssertEqual("Pink Floyd", $0.name)
            expectBoard.fulfill()
        }.store(in: &subs)
        
        Memory.shared.update.sink {
            XCTAssertEqual("Pink Floyd", $0.boards.first!.name)
            XCTAssertGreaterThanOrEqual($0.date, date)
            expectUser.fulfill()
        }.store(in: &subs)
        
        user.rename(board, "Pink Floyd")
        XCTAssertEqual("Pink Floyd", user.boards.first!.name)
        XCTAssertEqual(1, user.boards.first!.edit.count)
        XCTAssertGreaterThanOrEqual(user.date, date)
        if case let .rename(name) = user.boards.first!.edit.first!.actions.last! {
            XCTAssertEqual("Pink Floyd", name)
        } else {
            XCTFail()
        }
        waitForExpectations(timeout: 1)
    }
}
