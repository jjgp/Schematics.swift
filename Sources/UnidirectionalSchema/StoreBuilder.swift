import ReactiveSchema

public extension Store {
    struct Builder {
        private var dispatcher: Dispatcher?
        private var middleware: Middleware?
        private var mutation: Mutation<State>!
        private var subject: BindingValueSubject<State>!

        public func add(dispatcher: Dispatcher) -> Builder {
            update { builder in
                builder.dispatcher = dispatcher
            }
        }

        public func add(middleware: Middleware) -> Builder {
            update { builder in
                builder.middleware = middleware
            }
        }

        public func build() -> Store {
            .init(
                dispatcher: dispatcher ?? PassthroughDispatcher(),
                middleware: middleware,
                mutation: { _, _ in },
                subject: subject
            )
        }

        public func scope() -> Builder {
            fatalError()
        }

        @inline(__always)
        private func update(mutation: (inout Builder) -> Void) -> Builder {
            var builder = self
            mutation(&builder)
            return builder
        }
    }

    static func container(of _: State, updatingWith _: Mutation<State>) -> Builder {
        .init()
    }

    func container() -> Builder {
        fatalError()
    }

    func share() -> Builder {
        fatalError()
    }

    /*
     Store
        .container(of: Count(), updatingWith: mutation)
        .add()
        .add()
        .build()

     store
        .container()
        .add()
        .build()

     store
        .share() // or .clone()?
        .scope()
        .build()

     store
        .scope()
        .build()
     */
}
