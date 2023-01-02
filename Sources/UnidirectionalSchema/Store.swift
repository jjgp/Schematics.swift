import ReactiveSchema

public final class Store<State>: Publisher, StateContainer {
    private var dispatch: Dispatch<State>!
    private let dispatcher: Dispatcher
    private var subject: BindingValueSubject<State>

    init(
        dispatcher: Dispatcher,
        middleware: (any Middleware<State>)? = nil,
        subject: BindingValueSubject<State>
    ) {
        self.dispatcher = dispatcher
        self.subject = subject

        let dispatch: Dispatch<State> = { mutation in
            subject.send { state in
                mutation.mutate(state: &state)
            }
        }

        if let middleware = middleware {
            let container = eraseToAnyStateContainer()
            self.dispatch = { mutation in
                middleware.respond(to: mutation, sentTo: container, forwardingTo: dispatch)
            }
        } else {
            self.dispatch = dispatch
        }
    }

    public convenience init(
        dispatcher: Dispatcher = PassthroughDispatcher(),
        middleware: (any Middleware<State>)? = nil,
        state: State
    ) {
        self.init(
            dispatcher: dispatcher,
            middleware: middleware,
            subject: BindingValueSubject(state)
        )
    }

    public func scope<T>(
        middleware: (any Middleware<T>)? = nil,
        state keyPath: WritableKeyPath<State, T>
    ) -> Store<T> {
        .init(
            dispatcher: dispatcher,
            middleware: middleware,
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

    func send(_ mutation: any Mutation<State>) {
        dispatcher.receive(mutation: mutation, transmitTo: dispatch)
    }
}
