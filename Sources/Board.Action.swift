import Foundation

extension Board {
    enum Action: Equatable {
        case
        create,
        card,
        rename(String),
        move(Card.Position, Card.Position),
        recontent(Card.Position, String)
    }
}
