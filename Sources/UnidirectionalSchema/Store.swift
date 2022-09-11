import ReactiveSchema

public final class Store<State>: Publisher, StateContainer {
    private var dispatch: Dispatch!
    private let dispatcher: Dispatcher
    private var subject: BindingValueSubject<State>

    private init(
        dispatcher: Dispatcher,
        middleware: Middleware?,
        mutation: @escaping Mutation<State>,
        subject: BindingValueSubject<State>
    ) {
        self.dispatcher = dispatcher
        self.subject = subject

        let dispatch: Dispatch = { action in
            subject.send { state in
                mutation(&state, action)
            }
        }

        if let middleware = middleware {
            let container = eraseToAnyStateContainer()
            self.dispatch = { action in
                middleware.respond(to: action, sentTo: container, forwardingTo: dispatch)
            }
        } else {
            self.dispatch = dispatch
        }
    }

    public convenience init(
        dispatcher: Dispatcher = PassthroughDispatcher(),
        state: State,
        middleware: Middleware? = nil,
        mutation: @escaping Mutation<State>
    ) {
        self.init(
            dispatcher: dispatcher,
            middleware: middleware,
            mutation: mutation,
            subject: BindingValueSubject(state)
        )
    }

    public func eraseToAnyStateContainer() -> AnyStateContainer<State> {
        AnyStateContainer(
            getState: { [unowned self] in
                self.state
            },
            send: { [unowned self] action in
                self.send(action)
            }
        )
    }

    public func scope<T>(
        state keyPath: WritableKeyPath<State, T>,
        middleware: Middleware? = nil,
        mutation: @escaping Mutation<T>
    ) -> Store<T> {
        .init(
            dispatcher: dispatcher,
            middleware: middleware,
            mutation: mutation,
            subject: subject.scope(value: keyPath)
        )
    }
}

public extension Store {
    func subscribe(receiveValue: @escaping (State) -> Void) -> Cancellable {
        subject.subscribe(receiveValue: receiveValue)
    }
}

public extension Store {
    var state: State {
        subject.wrappedValue
    }

    func send(_ action: Action) {
        dispatcher.receive(action: action, transmitTo: dispatch)
    }
}
