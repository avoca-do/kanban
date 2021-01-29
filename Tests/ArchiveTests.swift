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
        Memory.shared.subs = .init()
    }
    
    func testSave() {
        let expect = expectation(description: "")
        let date = Date()
        Memory.shared.save.sink {
            XCTAssertGreaterThanOrEqual($0.date, date)
            expect.fulfill()
        }
        .store(in: &subs)
        archive.boards = []
        
        waitForExpectations(timeout: 1)
    }
    
    func testAdd() {
        let date = Date()
        archive.add()
        
        XCTAssertEqual(1, archive.boards.count)
        XCTAssertEqual(1, archive[0].edit.first!.actions.count)
        XCTAssertEqual(.create, archive[0].edit.first!.actions.first!)
        XCTAssertGreaterThanOrEqual(archive[0].edit.first!.date, date)
        XCTAssertGreaterThanOrEqual(archive.date, date)
    }
    
    func testRename() {
        archive.add()
        archive[0].rename("Pink Floyd")
        
        XCTAssertEqual("Pink Floyd", archive[0].name)
        XCTAssertEqual(1, archive[0].edit.count)
        if case let .rename(name) = archive[0].edit.first!.actions.last! {
            XCTAssertEqual("Pink Floyd", name)
        } else {
            XCTFail()
        }
    }
}
