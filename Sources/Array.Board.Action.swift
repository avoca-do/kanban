import Foundation

extension Array where Element == Board.Action {
    func compress(from state: [Board.Column], to columns: [Board.Column]) -> Self {
        columns.flatMap(\.cards).filter {
            state.fl
        }
    }
}
