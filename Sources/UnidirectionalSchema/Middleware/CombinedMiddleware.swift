public struct CombinedMiddleware: Middleware {
    private let middlewares: [Middleware]

    public init(_ middlewares: [Middleware]) {
        self.middlewares = middlewares
    }

    public init(_ middlewares: Middleware...) {
        self.init(middlewares)
    }

    public func respond<State>(
        to action: Action,
        sentTo container: AnyStateContainer<State>,
        forwardingTo next: Dispatch
    ) {
        var current: Action! = action

        for middleware in middlewares.reversed() {
            guard let action = current else {
                return
            }

            middleware.respond(to: action, sentTo: container, forwardingTo: { next in
                current = next
            })
        }

        next(current)
    }
}
