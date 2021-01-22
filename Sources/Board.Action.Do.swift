import Foundation

extension Board.Action {
    enum Do: Equatable {
        case
        create,
        rename(String)
    }
}
