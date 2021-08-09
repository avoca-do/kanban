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
    
    public func addColumn(board: Int) {
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .column))
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
    
    public func addCard(board: Int) {
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .card))
                }
        }
    }
}
