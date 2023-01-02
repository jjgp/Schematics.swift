public final class BarrierDispatcher: Dispatcher {
    private var buffer: [() -> Void] = []
    private var isDispatching = false

    public init() {}

    public func receive<State>(mutation: any Mutation<State>, transmitTo dispatch: @escaping Dispatch<State>) {
        guard !isDispatching else {
            buffer.append {
                dispatch(mutation)
            }
            return
        }

        isDispatching = true
        dispatch(mutation)
        var nextDispatch = 0
        while nextDispatch < buffer.count {
            buffer[nextDispatch]()
            nextDispatch += 1
        }
        buffer.removeAll()
        isDispatching = false
    }
}
