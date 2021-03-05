import Foundation

public enum Write: Equatable {
    case
    new(Path),
    edit(Path)
}
