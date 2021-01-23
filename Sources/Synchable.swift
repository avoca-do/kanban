import Foundation

protocol Synchable: Datable {
    associatedtype D : Describe where D.S == Self
    
    var descriptor: D { get }
}
