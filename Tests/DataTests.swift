import XCTest
@testable import Kanban

final class DataTests: XCTestCase {
    override func setUp() {
        Memory.shared = .init()
        Memory.shared.sub = nil
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
        archive.date = .init(timeIntervalSince1970: 150)
        
        var data = archive.data
        let archived = Archive(data: &data)
        XCTAssertEqual("hello world", archived.id)
        XCTAssertEqual(2, archived.boards.count)
        XCTAssertEqual(.init(timeIntervalSince1970: 150), archived.date)
        
        XCTAssertEqual(2, archived[0].edit.count)
        XCTAssertEqual(1, archived[0].edit.first!.actions.count)
        XCTAssertEqual(.create, archived[0].edit.first!.actions.first!)
        XCTAssertEqual(2, archived[0].edit.last!.actions.count)
        XCTAssertEqual(500, Int(archived[0].edit.first!.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardB.edit[1].date.timeIntervalSince1970), Int(archived[0].edit.last!.date.timeIntervalSince1970))
        XCTAssertEqual("total recall", archived[0].name)
        
        if case let .rename(name) = archived[0].edit.last!.actions.first! {
            XCTAssertEqual("lorem ipsum", name)
        } else {
            XCTFail()
        }
        
        if case let .rename(name) = archived[0].edit.last!.actions.last! {
            XCTAssertEqual("total recall", name)
        } else {
            XCTFail()
        }

        XCTAssertEqual(1, archived[1].edit.count)
        XCTAssertEqual(1, archived[1].edit.first!.actions.count)
        XCTAssertEqual(.create, archived[1].edit.first!.actions.first!)
        XCTAssertEqual(300, Int(archived[1].edit.first!.date.timeIntervalSince1970))
        XCTAssertEqual(.init(boardA.edit[0].date.timeIntervalSince1970), Int(archived[1].edit.last!.date.timeIntervalSince1970))
        
        XCTAssertEqual(3, archived[0].count)
        XCTAssertEqual("Do", archived[0][0].title)
        XCTAssertEqual("Doing", archived[0][1].title)
        XCTAssertEqual("Done", archived[0][2].title)
    }
}
