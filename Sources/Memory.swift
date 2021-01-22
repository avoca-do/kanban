import Foundation
import Combine

final class Memory {
    static var shared = Memory()
    let save = PassthroughSubject<Board, Never>()
}
