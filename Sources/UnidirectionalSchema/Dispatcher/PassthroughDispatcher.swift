public struct PassthroughDispatcher: Dispatcher {
    public init() {}

    @inlinable
    public func receive(action: Action, transmitTo dispatch: @escaping Dispatch) {
        dispatch(action)
    }
}
