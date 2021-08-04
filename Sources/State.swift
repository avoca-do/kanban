import Foundation

public enum State: Equatable {
    case
    none,
    create,
    view(Int),
    new(Path),
    edit(Path)
}
