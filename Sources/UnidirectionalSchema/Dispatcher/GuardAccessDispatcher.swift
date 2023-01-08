///
public struct GuardAccessDispatcher: Dispatcher {
    ///
    public init() {}

    ///
    @inlinable
    public func receive<State>(mutation: any Mutation<State>, transmitTo dispatch: @escaping Dispatch<State>) {
        // TODO: Implement similair to https://github.com/spotify/Mobius.swift/blob/master/MobiusCore/Source/ConcurrentAccessDetector.swift
        dispatch(mutation)
    }
}
