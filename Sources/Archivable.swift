import Foundation

protocol Archivable {
    var data: Data { get }
    
    init(data: inout Data)
}
