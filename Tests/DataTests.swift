import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    func testBits() {
        XCTAssertTrue(Data().add([]).isEmpty)
        XCTAssertEqual(1, Data().add([false]).count)
        XCTAssertEqual(2, Data().add([false]).add([true, true, true, true, true, true, true, true]).count)
        XCTAssertEqual([false, true, false, false, false, false, false, false],
                       Data().add([false, true, false, false, false, false, false, false]).bits)
        XCTAssertEqual([false, true, false, false, false, false, true, true],
                       Data().add([false, true, false, false, false, false, true, true]).bits)
        XCTAssertEqual([true, true, true, true, true, true, true, true],
                       Data().add([true, true, true, true, true, true, true, true]).bits)
    }
}
