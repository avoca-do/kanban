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
    
    func testAdd() {
        let expect = expectation(description: "")
        let date = Date()
        XCTAssertTrue(cloud.archive.value.isEmpty(.archive))
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
    
    /*
    
    func testCount() {
        XCTAssertEqual(0, archive.count(.archive))
        archive.add()
        XCTAssertEqual(3, archive.count(.board(0)))
        XCTAssertEqual(0, archive.count(.column(.board(0), 0)))
    }
    
    func testName() {
        archive.add()
        archive.boards[0].name = "hello world"
        XCTAssertEqual("hello world", archive[name: .board(0)])
        XCTAssertEqual("DO", archive[title: .column(.board(0), 0)])
    }
    
    func testIndexOutOfBounds() {
        XCTAssertNotNil(archive[.board(0)])
    }
    
    func testComparison() {
        var archiveA = Archive.new
        let archiveB = Archive.new
        XCTAssertEqual(archiveA, archiveB)
        archiveA.capacity = 2
        XCTAssertNotEqual(archiveA, archiveB)
        XCTAssertGreaterThan(archiveA, archiveB)
    }*/
}
