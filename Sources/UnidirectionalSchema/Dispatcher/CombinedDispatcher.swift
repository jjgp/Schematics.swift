public struct CombinedDispatcher: Dispatcher {
    private let dispatchers: [Dispatcher]

    public init(_ dispatchers: [Dispatcher]) {
        self.dispatchers = dispatchers
    }

    public init(_ dispatchers: Dispatcher...) {
        self.init(dispatchers)
    }

    public func receive<State>(mutation: any Mutation<State>, transmitTo dispatch: @escaping Dispatch<State>) {
        var dispatch = dispatch

        for dispatcher in dispatchers.reversed() {
            dispatch = { [dispatch] mutation in
                dispatcher.receive(mutation: mutation, transmitTo: dispatch)
            }
        }

        dispatch(mutation)
    }
}
