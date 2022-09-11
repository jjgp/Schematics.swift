public struct CombinedDispatcher: Dispatcher {
    private let dispatchers: [Dispatcher]

    public init(_ dispatchers: [Dispatcher]) {
        self.dispatchers = dispatchers
    }

    public init(_ dispatchers: Dispatcher...) {
        self.init(dispatchers)
    }

    public func receive(action: Action, transmitTo dispatch: @escaping Dispatch) {
        var dispatch = dispatch

        for dispatcher in dispatchers.reversed() {
            dispatch = { [dispatch] action in
                dispatcher.receive(action: action, transmitTo: dispatch)
            }
        }

        dispatch(action)
    }
}
