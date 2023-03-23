///
public protocol StateContainer<State>: AnyObject {
    ///
    associatedtype State

    ///
    var state: State { get }

    ///
    func eraseToAnyStateContainer() -> any StateContainer<State>

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

    func eraseToAnyStateContainer() -> any StateContainer<State> {
        self
    }
}

public extension StateContainer {
    ///
    func eraseToAnyStateContainer() -> any StateContainer<State> {
        AnyStateContainer(self)
    }

    ///
    func toUnownedStateContainer() -> any StateContainer<State> {
        AnyStateContainer(
            getState: { [unowned self] in
                self.state
            },
            send: { [unowned self] mutation in
                self.send(mutation)
            }
        )
    }
}
