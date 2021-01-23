import Foundation

protocol Describe: Datable {
    associatedtype S : Synchable where S.D == Self
    
    init(describe: S)
}
