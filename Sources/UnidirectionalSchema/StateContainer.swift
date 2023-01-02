///
public protocol StateContainer: AnyObject {
    ///
    associatedtype State

    ///
    var state: State { get }

    ///
    func send(_ mutation: any Mutation<State>)
}

///
public final class AnyStateContainer<State>: StateContainer {
    private let getState: () -> State
    private let dispatch: Dispatch<State>

    ///
    public init(getState: @escaping () -> State, send: @escaping Dispatch<State>) {
        self.getState = getState
        dispatch = send
    }

    ///
    public convenience init<S: StateContainer>(_ container: S) where S.State == State {
        self.init(getState: { container.state }, send: container.send(_:))
    }
}

public extension AnyStateContainer {
    ///
    var state: State {
        getState()
    }

    ///
    func send(_ mutation: any Mutation<State>) {
        dispatch(mutation)
    }
}

public extension StateContainer {
    ///
    func eraseToAnyStateContainer() -> AnyStateContainer<State> {
        .init(self)
    }
}
