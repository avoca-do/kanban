import XCTest
@testable import Kanban

final class KanbanTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Kanban().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
