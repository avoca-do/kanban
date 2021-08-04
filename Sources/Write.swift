import Foundation

public enum Write: Equatable {
    case
    none,
    new(Path),
    edit(Path)
}
