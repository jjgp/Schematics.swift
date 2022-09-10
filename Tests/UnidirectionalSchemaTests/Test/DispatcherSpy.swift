import UnidirectionalSchema

public final class DispatcherSpy: Dispatcher {
    public var buffer: [() -> Action] = []
    public var dispatched: [Action] = []

    public init() {}
}

public extension DispatcherSpy {
    func receive(action: Action, transmitTo dispatch: @escaping Dispatch) {
        buffer.append {
            dispatch(action)
            return action
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
