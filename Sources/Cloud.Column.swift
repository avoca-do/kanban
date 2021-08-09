import Foundation
import Archivable

extension Cloud where A == Archive {
    public func rename(board: Int, column: Int, name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        mutating {
            guard $0[board][column].name != name else { return }
            $0
                .items
                .mutate(index: board) {
                    $0
                        .with(snaps: $0
                                .snaps
                                .adding(action: .name(column, name)))
                }
        }
    }
}
