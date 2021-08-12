import XCTest
@testable import Kanban

final class ActivityTests: XCTestCase {
    func testBoardEmpty() {
        XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], Board()
                        .with(snaps: [])
                        .activity(period: .week))
    }
    
    func testBoardInitial() {
        XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 1], Board().activity(period: .week))
    }
    
    func testBoardWeek() {
        var board = Board()
        var data0 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 6.9).timestamp)
            .adding(UInt8(0))
        var data1 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 6.1).timestamp)
            .adding(UInt8(0))
        var data2 = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 5.5).timestamp)
            .adding(UInt8(0))
        board = board
            .with(snaps: [.init(data: &data0, after: nil), .init(data: &data1, after: nil), .init(data: &data2, after: nil)])
        
        XCTAssertEqual([1, 1, 1, 0, 0, 0, 0, 0, 0, 0], board.activity(period: .week))
    }
    
    func testBoardIgnoreOlder() {
        var board = Board()
        var data = Data()
            .adding(Date(timeIntervalSinceNow: -60 * 60 * 24 * 8).timestamp)
            .adding(UInt8(board.snaps[0].state.actions.count))
            .adding(board.snaps[0].state.actions.flatMap(\.data))
        board = board
            .with(snaps: [.init(data: &data, after: nil)])
        board =  board
            .with(snaps: board
                    .snaps
                    .adding(action: .card))
        
        XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 1], board.activity(period: .week))
    }
}
