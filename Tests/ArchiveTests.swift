import XCTest
import Combine
@testable import Kanban

final class ArchiveTests: XCTestCase {
    private var archive: Archive!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        archive = .init()
        subs = .init()
        Memory.shared = .init()
    }
    
    func testAdd() {
        let expect = expectation(description: "")
        let date = Date()
        Memory.shared.save.sink {
            XCTAssertEqual(1, $0.count)
            expect.fulfill()
        }.store(in: &subs)
        
        archive.add()
        XCTAssertEqual(1, archive.boards.count)
        XCTAssertEqual(1, archive[0].edit.first!.actions.count)
        XCTAssertEqual(.create, archive[0].edit.first!.actions.first!)
        XCTAssertGreaterThanOrEqual(archive[0].edit.first!.date, date)
        waitForExpectations(timeout: 1)
    }
}
