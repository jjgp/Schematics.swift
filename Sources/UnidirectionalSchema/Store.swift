import ReactiveSchema

///
public final class Store<State>: Publisher, StateContainer {
    private var dispatch: Dispatch<State>!
    private let dispatcher: Dispatcher
    private var subject: BindingValueSubject<State>

    init(
        dispatch: @escaping Dispatch<State>,
        dispatcher: Dispatcher,
        middleware: (any Middleware<State>)? = nil,
        subject: BindingValueSubject<State>
    ) {
        self.dispatcher = dispatcher
        self.subject = subject

        if let middleware = middleware {
            let container = toUnownedStateContainer()

            self.dispatch = { mutation in
                middleware.respond(to: mutation, passedTo: container, forwardingTo: dispatch)
            }

            middleware.prepare(for: container)
        } else {
            self.dispatch = dispatch
        }
    }

    convenience init(dispatcher: Dispatcher, middleware: (any Middleware<State>)? = nil, subject: BindingValueSubject<State>) {
        let dispatch: Dispatch<State> = { mutation in
            subject.send { state in
                mutation.mutate(state: &state)
            }
        }

        self.init(dispatch: dispatch, dispatcher: dispatcher, middleware: middleware, subject: subject)
    }

    ///
    public convenience init(
        dispatcher: Dispatcher = PassthroughDispatcher(),
        middleware: (any Middleware<State>)? = nil,
        state: State
    ) {
        self.init(dispatcher: dispatcher, middleware: middleware, subject: BindingValueSubject(state))
    }

    ///
    public func scope<Substate>(
        middleware: (any Middleware<Substate>)? = nil,
        state keyPath: WritableKeyPath<State, Substate>
    ) -> Store<Substate> {
        let dispatch: Dispatch<Substate> = { mutation in
            self.dispatch(Mutations.Scope(mutation: mutation, state: keyPath))
        }

        return .init(
            dispatch: dispatch,
            dispatcher: dispatcher,
            middleware: middleware,
            subject: subject.scope(value: keyPath)
        )
    }

    ///
    public func extend(middleware: any Middleware<State>) -> Store<State> {
        let dispatch: Dispatch<State> = { mutation in
            self.dispatch(mutation)
        }

        return .init(dispatch: dispatch, dispatcher: dispatcher, middleware: middleware, subject: subject)
    }
}

public extension Store {
    ///
    func subscribe(receiveValue: @escaping (State) -> Void) -> Cancellable {
        subject.subscribe(receiveValue: receiveValue)
    }
}

public extension Store {
    ///
    var state: State {
        subject.wrappedValue
    }

    ///
    func send(_ mutation: any Mutation<State>) {
        dispatcher.receive(mutation: mutation, transmitTo: dispatch)
    }
}

public extension Mutations {
    ///
    struct Scope<State, Substate>: Mutation {
        ///
        public let keyPath: WritableKeyPath<State, Substate>
        ///
        public let mutation: any Mutation<Substate>

        public init(mutation: any Mutation<Substate>, state keyPath: WritableKeyPath<State, Substate>) {
            self.keyPath = keyPath
            self.mutation = mutation
        }

        ///
        public func mutate(state: inout State) {
            mutation.mutate(state: &state[keyPath: keyPath])
        }
    }
}
