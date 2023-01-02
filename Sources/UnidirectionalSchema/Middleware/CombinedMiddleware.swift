public struct CombinedMiddleware<State>: Middleware {
    private let middlewares: [any Middleware<State>]

    public init(_ middlewares: [any Middleware<State>]) {
        self.middlewares = middlewares
    }

    public init(_ middlewares: any Middleware<State>...) {
        self.init(middlewares)
    }

    public func respond(
        to mutation: any Mutation<State>,
        sentTo container: AnyStateContainer<State>,
        forwardingTo next: Dispatch<State>
    ) {
        var current: (any Mutation<State>)! = mutation

        for middleware in middlewares.reversed() {
            guard let mutation = current else {
                return
            }

            middleware.respond(to: mutation, sentTo: container, forwardingTo: { next in
                current = next
            })
        }

        next(current)
    }
}
