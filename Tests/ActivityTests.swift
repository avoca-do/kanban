import XCTest
@testable import Kanban

final class ActivityTests: XCTestCase {
    private var archive: Archive!
    
    override func setUp() {
        archive = .init()
        Memory.shared = .init()
        Memory.shared.subs = .init()
        archive.boards = [.init(), .init(), .init()]
    }
    
    func testWeek() {
        var data0 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 6).timestamp)
            .adding(UInt8(archive.boards[0].snaps[0].state.actions.count))
            .adding(archive.boards[0].snaps[0].state.actions.flatMap(\.data))
        var data1 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 5).timestamp)
            .adding(UInt8(0))
        archive.boards[0].snaps[0] = Board.Snap(data: &data0, after: nil)
        archive.boards[0].card()
        archive.boards[0].snaps[1] = Board.Snap(data: &data1, after: nil)
        
        data0 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 4).timestamp)
            .adding(UInt8(archive.boards[1].snaps[0].state.actions.count))
            .adding(archive.boards[1].snaps[0].state.actions.flatMap(\.data))
        data1 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 3).timestamp)
            .adding(UInt8(0))
        archive.boards[1].snaps[0] = Board.Snap(data: &data0, after: nil)
        archive.boards[1].card()
        archive.boards[1].snaps[1] = Board.Snap(data: &data1, after: nil)
        
        XCTAssertEqual([
                        [1, 1, 0, 0, 0, 0],
                        [0, 0, 1, 1, 0, 0],
                        [0, 0, 0, 0, 0, 1]], archive[activity: .week])
    }
}
