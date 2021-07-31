import XCTest
import Combine
import Archivable
@testable import Kanban

final class CloudTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    private var subs: Set<AnyCancellable>!
    
    override func setUp() {
        cloud = .init(manifest: nil)
        subs = []
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(cloud.archive.value[.board(0)])
    }
    
    func testAdd() {
        let expect = expectation(description: "")
        let date = Date()
        XCTAssertTrue(cloud.archive.value.isEmpty(.archive))
        XCTAssertEqual(0, cloud.archive.value.count(.archive))
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(1, $0.count(.archive))
                XCTAssertEqual(1, $0[.board(0)].snaps.first!.state.actions.count)
                XCTAssertEqual(.create, $0[.board(0)].snaps.first!.state.actions.first!)
                XCTAssertGreaterThanOrEqual($0[.board(0)].snaps.first!.state.date, date)
                XCTAssertGreaterThanOrEqual($0.date(.archive), date)
                XCTAssertFalse($0.isEmpty(.board(0)))
                XCTAssertTrue($0.isEmpty(.column(.board(0), 0)))
                XCTAssertFalse($0.isEmpty(.archive))
                XCTAssertEqual(3, $0.count(.board(0)))
                XCTAssertEqual(0, $0.count(.column(.board(0), 0)))
                XCTAssertEqual("DO", $0[.board(0)].name)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.add()
        waitForExpectations(timeout: 1)
    }
    
    func testSaveCapacity() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst()
            .sink {
                XCTAssertEqual(2, $0.capacity)
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.purschase()
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertTrue($0.isEmpty(.archive))
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.add()
        cloud.delete(.board(0))
        waitForExpectations(timeout: 1)
    }
    
    func testName() {
        let expect = expectation(description: "")
        cloud
            .archive
            .dropFirst(2)
            .sink {
                XCTAssertEqual("hello world", $0[name: .board(0)])
                expect.fulfill()
            }
            .store(in: &subs)
        cloud.add()
        cloud.board(path: .board(0), name: "hello world")
        waitForExpectations(timeout: 1)
    }
}
