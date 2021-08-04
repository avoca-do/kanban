import Foundation

public enum State: Equatable {
    case
    none,
    view(Path),
    new(Path),
    edit(Path)
}
