import Foundation

///
public struct OnQueueDispatcher: Dispatcher {
    private let key = DispatchSpecificKey<UInt8>()
    private let queue: DispatchQueue
    private let value: UInt8 = 0

    ///
    public init(_ queue: DispatchQueue = .main) {
        self.queue = queue
        queue.setSpecific(key: key, value: value)
    }

    ///
    public func receive<State>(mutation: any Mutation<State>, transmitTo dispatch: @escaping Dispatch<State>) {
        if DispatchQueue.getSpecific(key: key) == value {
            dispatch(mutation)
        } else {
            queue.async {
                dispatch(mutation)
            }
        }
    }
}
