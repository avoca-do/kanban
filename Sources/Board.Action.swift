import Foundation

extension Board {
    enum Action: Equatable {
        case
        create,
        rename(String)
    }
}
