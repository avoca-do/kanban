import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    override func setUp() {
        Memory.shared = .init()
    }
    
    func testArchive() {
        var boardA = Board()
        boardA.edit[boardA.edit.count - 1].date = .init(timeIntervalSince1970: 300)
        var boardB = Board()
        boardB.edit[0].date = .init(timeIntervalSince1970: 500)
        boardB.rename("lorem ipsum")
        boardB.rename("total recall")
        
        var archive = Archive()
        archive.id = "hello world"
        archive.boards = [boardB, boardA]
        XCTAssertEqual("hello world", Archive(data: archive.data).id)
        XCTAssertEqual(2, Archive(data: archive.data).boards.count)
        
        XCTAssertEqual(2, Archive(data: archive.data)[0].edit.count)
        XCTAssertEqual(1, Archive(data: archive.data)[0].edit.first!.actions.count)
        XCTAssertEqual(.create, Archive(data: archive.data)[0].edit.first!.actions.first!)
        XCTAssertEqual(3, Archive(data: archive.data)[0].edit.last!.actions.count)
        XCTAssertEqual(.create, Archive(data: archive.data)[0].edit.last!.actions.first!)
        XCTAssertEqual(500, Int(Archive(data: archive.data)[0].edit.first!.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardB.edit[1].date.timeIntervalSince1970), Int(Archive(data: archive.data)[0].edit.last!.date.timeIntervalSince1970))
        XCTAssertEqual("total recall", Archive(data: archive.data)[0].name)
        
        if case let .rename(name) = Archive(data: archive.data)[0].edit.last!.actions[1] {
            XCTAssertEqual("lorem ipsum", name)
        } else {
            XCTFail()
        }
        
        if case let .rename(name) = Archive(data: archive.data)[0].edit.last!.actions.last! {
            XCTAssertEqual("total recall", name)
        } else {
            XCTFail()
        }

        XCTAssertEqual(1, Archive(data: archive.data)[1].edit.count)
        XCTAssertEqual(1, Archive(data: archive.data)[1].edit.first!.actions.count)
        XCTAssertEqual(.create, Archive(data: archive.data)[1].edit.first!.actions.first!)
        XCTAssertEqual(300, Int(Archive(data: archive.data)[1].edit.first!.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardA.edit[0].date.timeIntervalSince1970), Int(Archive(data: archive.data)[1].edit.last!.date.timeIntervalSince1970))
    }
}
