import Foundation

public enum State: Equatable {
    case
    none,
    view(Int),
    new(Path),
    edit(Path)
}
