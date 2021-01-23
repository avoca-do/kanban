import Foundation

protocol Describe: Datable {
    associatedtype S : Synchable where S.D == Self

    var described: S { get }
    
    init(describe: S)
}
