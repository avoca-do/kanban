import Foundation
import Archivable

extension Cloud where A == Archive {
    public func rename(board: Int, name: String) {
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0.with(name: name)
                }
        }
    }
    
    public func add(board: Int, column: String) {
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .column)
                                .adding(action: .name($0.count, column
                                                        .trimmingCharacters(in: .whitespacesAndNewlines))))
                }
        }
    }
    
    public func add(board: Int, card: String) {
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .card)
                                .adding(action: .content($0.snaps.last!.counter, card
                                                            .trimmingCharacters(in: .whitespacesAndNewlines))))
                }
        }
    }
    
    public func delete(board: Int, column: Int) {
        mutating {
            guard
                $0.count > board,
                $0[board].count > column
            else { return }
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .drop(column)))
                }
        }
    }
}
