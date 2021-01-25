import Foundation
import Combine

protocol Describe: Datable {
    associatedtype S : Synchable where S.D == Self

    var described: Future<S, Never> { get }
    
    init(describe: S)
}
