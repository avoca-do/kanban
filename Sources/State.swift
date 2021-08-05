import Foundation

public enum State: Equatable {
    case
    none,
    create,
    view(Int),
    column(Int),
    card(Int),
    edit(Path)
}
