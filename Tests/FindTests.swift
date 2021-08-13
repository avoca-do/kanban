import XCTest
import Archivable
@testable import Kanban

final class FindTests: XCTestCase {
    private var cloud: Cloud<Archive>!
    
    override func setUp() {
        cloud = .init(manifest: nil)
    }
    
    func testNew() {
        let expect = expectation(description: "")
        cloud
            .find(search: "hello") {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testEmptySearch() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "") {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testNotMatching() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "recall") {
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
    
    func testBoardName() {
        let expect = expectation(description: "")
        cloud.new(board: "hello world", completion: { })
        cloud.add(board: 0, card: "lorem ipsum")
        cloud
            .find(search: "hell") {
                XCTAssertEqual("hello world", $0.first?.value)
                XCTAssertEqual(.board(0), $0.first?.path)
                XCTAssertEqual(1, $0.count)
                expect.fulfill()
            }
        waitForExpectations(timeout: 1)
    }
}
