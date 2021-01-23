import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    func testUser() {
        var boardA = Board(id: 0)
        boardA.edit[boardA.edit.count - 1].date = .distantPast
        var boardB = Board(id: 8000)
        boardB.edit[boardB.edit.count - 1].date = .distantFuture
        var user = User()
        user.counter = 99
        user.id = "hello world"
        user.boards = [boardB, boardA]
//        let parsed = Data(user: user).user
//        XCTAssertEqual(user.id, parsed?.id)
//        XCTAssertEqual(user.deleted, parsed?.deleted)
//        XCTAssertEqual(user.id, parsed?.id)
    }
}
