import ReactiveSchema

///
public final class Store<State>: Publisher, StateContainer {
    private var dispatch: Dispatch<State>!
    private let dispatcher: Dispatcher
    private var subject: BindingValueSubject<State>

    init(
        dispatch: Dispatch<State>!,
        dispatcher: Dispatcher,
        middleware: (any Middleware<State>)? = nil,
        subject: BindingValueSubject<State>
    ) {
        self.dispatcher = dispatcher
        self.subject = subject

        if let middleware = middleware {
            middleware.attachTo(eraseToAnyStateContainer())

            self.dispatch = { mutation in
                middleware.respond(to: mutation, forwardingTo: dispatch)
            }
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
    public func scope<T>(middleware: (any Middleware<T>)? = nil, state keyPath: WritableKeyPath<State, T>) -> Store<T> {
        let dispatch: Dispatch<T> = { [unowned self] mutation in
            self.dispatch(Mutations.Scope(mutation: mutation, state: keyPath))
        }

        return .init(
            dispatch: dispatch,
            dispatcher: dispatcher,
            middleware: middleware,
            subject: subject.scope(value: keyPath)
        )
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
    func eraseToAnyStateContainer() -> AnyStateContainer<State> {
        AnyStateContainer(
            getState: { [unowned self] in
                self.state
            },
            send: { [unowned self] mutation in
                self.send(mutation)
            }
        )
    }

    ///
    func send(_ mutation: any Mutation<State>) {
        dispatcher.receive(mutation: mutation, transmitTo: dispatch)
    }
}
