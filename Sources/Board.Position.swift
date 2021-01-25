import Foundation

extension Board.Edit {
    struct Position: Equatable, Archivable {
        let column: Int
        let index: Int
        
        var data: Data {
            .init()
        }
        
        init(data: inout Data) {
            fatalError()
        }
    }
}
