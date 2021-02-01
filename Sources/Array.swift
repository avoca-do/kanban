import Foundation

extension Array {
    func mutating(index: Int, transform: (Element) -> Element) -> Self {
        var array = self
        array[index] = transform(array[index])
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
