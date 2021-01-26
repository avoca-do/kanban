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
        Memory.shared.sub = nil
    }
    
    func testAdd() {
        let expect = expectation(description: "")
        let date = Date()
        archive.date = .distantPast
        Memory.shared.save.sink {
            XCTAssertEqual(1, $0.count)
            XCTAssertGreaterThanOrEqual($0.date, date)
            expect.fulfill()
        }.store(in: &subs)
        
        archive.add()
        XCTAssertEqual(1, archive.boards.count)
        XCTAssertEqual(1, archive[0].edit.first!.actions.count)
        XCTAssertEqual(.create, archive[0].edit.first!.actions.first!)
        XCTAssertGreaterThanOrEqual(archive[0].edit.first!.date, date)
        XCTAssertGreaterThanOrEqual(archive.date, date)
        waitForExpectations(timeout: 1)
    }
    
    func testRename() {
        let expect = expectation(description: "")
        archive.add()
        let date = Date()
        archive.date = .distantPast
        
        Memory.shared.save.sink {
            XCTAssertEqual("Pink Floyd", $0.boards[0].name)
            XCTAssertGreaterThanOrEqual($0.date, date)
            expect.fulfill()
        }.store(in: &subs)
        
        archive[0].rename("Pink Floyd")
        XCTAssertEqual("Pink Floyd", archive[0].name)
        XCTAssertEqual(1, archive[0].edit.count)
        XCTAssertGreaterThanOrEqual(archive.date, date)
        if case let .rename(name) = archive[0].edit.first!.actions.last! {
            XCTAssertEqual("Pink Floyd", name)
        } else {
            XCTFail()
        }
        waitForExpectations(timeout: 1)
    }
}
