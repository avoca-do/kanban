import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    func testUser() {
        var boardA = Board(id: 0)
        boardA.edit[boardA.edit.count - 1].date = .init(timeIntervalSince1970: 300)
        var boardB = Board(id: 8000)
        boardB.edit[0].date = .init(timeIntervalSince1970: 500)
        boardB.edit.append(.init(actions: [], date: .init(timeIntervalSince1970: 800)))
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
        XCTAssertEqual(Int(Date(timeIntervalSince1970: 800).timeIntervalSince1970), .init(User.Descriptor(data: user.descriptor.data).boards.first!.date.timeIntervalSince1970))
        XCTAssertEqual(0, User.Descriptor(data: user.descriptor.data).boards.last?.id)
        XCTAssertEqual(Int(Date(timeIntervalSince1970: 300).timeIntervalSince1970), .init(User.Descriptor(data: user.descriptor.data).boards.last!.date.timeIntervalSince1970))
    }
}
