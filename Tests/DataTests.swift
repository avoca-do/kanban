import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    func testUser() {
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
        XCTAssertEqual(Int(user.date.timeIntervalSince1970), .init(User.Descriptor(data: user.descriptor.data).date.timeIntervalSince1970))
        XCTAssertEqual(user.id, User.Descriptor(data: user.descriptor.data).id)
        XCTAssertEqual(user.counter, User.Descriptor(data: user.descriptor.data).counter)
        XCTAssertEqual(2, User.Descriptor(data: user.descriptor.data).boards.count)
        XCTAssertEqual(8000, User.Descriptor(data: user.descriptor.data).boards.first?.id)
        XCTAssertEqual(.distantFuture, User.Descriptor(data: user.descriptor.data).boards.first?.date)
        XCTAssertEqual(0, User.Descriptor(data: user.descriptor.data).boards.last?.id)
        XCTAssertEqual(.distantPast, User.Descriptor(data: user.descriptor.data).boards.last?.date)
    }
}
