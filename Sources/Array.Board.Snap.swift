import Foundation

extension Array where Element == Board.Snap {
    func adding(action: Board.Action) -> Self {
        var snaps = self
        
        if isEmpty
            || (Calendar.current.dateComponents([.hour], from: last!.state.date, to: .init()).hour! > 0
                    && !last!.state.actions.isEmpty) {
            snaps.append(.init(after: snaps.last))
        }
        
        snaps[snaps.count - 1].add(action, snaps.count > 1 ? snaps[snaps.count - 2] : nil)
        return snaps
    }
}
