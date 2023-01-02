public struct PassthroughDispatcher: Dispatcher {
    public init() {}

    @inlinable
    public func receive<State>(mutation: any Mutation<State>, transmitTo dispatch: @escaping Dispatch<State>) {
        dispatch(mutation)
    }
}
