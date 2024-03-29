///
public struct CombinedMiddleware<State>: Middleware {
    private let middlewares: [any Middleware<State>]

    ///
    public init(_ middlewares: [any Middleware<State>]) {
        self.middlewares = middlewares
    }

    ///
    public init(_ middlewares: any Middleware<State>...) {
        self.init(middlewares)
    }

    ///
    public func attach(to container: any StateContainer<State>) {
        middlewares.forEach {
            $0.attach(to: container)
        }
    }

    ///
    public func detach(from container: any StateContainer<State>) {
        middlewares.forEach {
            $0.detach(from: container)
        }
    }

    ///
    public func respond(
        to mutation: any Mutation<State>,
        passedTo container: any StateContainer<State>,
        forwardingTo next: Dispatch<State>
    ) {
        var current: (any Mutation<State>)! = mutation

        for middleware in middlewares.reversed() {
            guard let mutation = current else {
                return
            }

            middleware.respond(to: mutation, passedTo: container, forwardingTo: { next in
                current = next
            })
        }

        next(current)
    }
}
