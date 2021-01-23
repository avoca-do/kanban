import Foundation

protocol Datable {
    var data: Data { get }
    
    init?(data: Data)
}
