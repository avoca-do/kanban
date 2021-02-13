import Foundation

extension Array {
    func mutating(index: Int, transform: (Element) -> Element) -> Self {
        var array = self
        array[index] = transform(array[index])
        return array
    }
    
    func moving(from: Int, to: Int) -> Self {
        var array = self
        array.insert(array.remove(at: from), at: Swift.min(to, array.count))
        return array
    }
    
    func removing(index: Int) -> Self {
        var array = self
        array.remove(at: index)
        return array
    }
    
    static func +(array: Self, element: Element) -> Self {
        var array = array
        array.append(element)
        return array
    }
    
    static func +(element: Element, array: Self) -> Self {
        var array = array
        array.insert(element, at: 0)
        return array
    }
}
