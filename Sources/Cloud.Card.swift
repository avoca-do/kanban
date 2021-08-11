import Foundation
import Archivable

extension Cloud where A == Archive {
    public func update(board: Int, column: Int, card: Int, content: String) {
        let content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        mutating {
            guard $0[board][column][card].content != content else { return }
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .content($0[column][card].id, content)))
                }
        }
    }
    
    public func move(board: Int, column: Int, card: Int, vertical: Int) {
        guard card != vertical else { return }
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .vertical($0[column][card].id, vertical)))
                }
        }
    }
    
    public func move(board: Int, column: Int, card: Int, horizontal: Int) {
        guard column != horizontal else { return }
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .horizontal($0[column][card].id, horizontal)))
                }
        }
    }
    
    public func move(board: Int, column: Int, card: Int, horizontal: Int, vertical: Int) {
        guard column != horizontal else { return }
        mutating {
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .horizontal($0[column][card].id, horizontal))
                                .adding(action: .vertical($0[column][card].id, vertical)))
                }
        }
    }
    
    public func delete(board: Int, column: Int, card: Int) {
        mutating {
            guard
                $0.count > board,
                $0[board].count > column,
                $0[board][column].count > card
            else { return }
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .remove($0[column][card].id)))
                }
        }
    }
}
