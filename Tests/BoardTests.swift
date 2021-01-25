import XCTest
import Combine
@testable import Kanban

final class BoardTests: XCTestCase {
    private var archive: Archive!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        archive = .init()
        subs = .init()
        Memory.shared = .init()
    }
    
    func testRename() {
        let expect = expectation(description: "")
        archive.add()
        
        Memory.shared.save.sink {
            XCTAssertEqual("Pink Floyd", $0.boards[0].name)
            expect.fulfill()
        }.store(in: &subs)
        
        archive[0].rename("Pink Floyd")
        XCTAssertEqual("Pink Floyd", archive[0].name)
        XCTAssertEqual(1, archive[0].edit.count)
        if case let .rename(name) = archive[0].edit.first!.actions.last! {
            XCTAssertEqual("Pink Floyd", name)
        } else {
            XCTFail()
        }
        waitForExpectations(timeout: 1)
    }
}
