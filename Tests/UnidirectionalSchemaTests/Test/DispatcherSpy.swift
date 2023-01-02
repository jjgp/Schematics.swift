import UnidirectionalSchema

public final class DispatcherSpy: Dispatcher {
    public var buffer: [() -> any Mutation] = []
    public var dispatched: [any Mutation] = []

    public init() {}
}

public extension DispatcherSpy {
    func receive<State>(mutation: any Mutation<State>, transmitTo dispatch: @escaping Dispatch<State>) {
        buffer.append {
            dispatch(mutation)
            return mutation
        }
    }
}

public extension DispatcherSpy {
    func dispatch() {
        dispatched.append(buffer.removeFirst()())
    }

    func dispatched<T>(at index: Int) -> T? {
        dispatched[index] as? T
    }

    func dispatched<Action>(between range: ClosedRange<Int>) -> Action? {
        for other in dispatched[range] {
            if let other = other as? Action {
                return other
            }
        }

        return nil
    }
}
