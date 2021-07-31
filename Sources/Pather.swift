import Foundation

public protocol Pather {
    associatedtype Item : PatherItem
    
    var items: [Item] { get }
}

extension Pather {
    var count: Int {
        items.count
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    subscript(_ index: Int) -> Item {
        index >= 0 && index < items.count ? items[index] : .init()
    }
}
