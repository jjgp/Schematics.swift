public struct CombinedMiddleware: Middleware {
    private let middlewares: [Middleware]

    public init(_ middlewares: [Middleware]) {
        self.middlewares = middlewares
    }

    public init(_ middlewares: Middleware...) {
        self.init(middlewares)
    }

    public func respond<State>(
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
