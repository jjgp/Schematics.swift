public struct CombinedMiddleware<State>: Middleware {
    private let middlewares: [any Middleware<State>]

    public init(_ middlewares: [any Middleware<State>]) {
        self.middlewares = middlewares
    }

    public init(_ middlewares: any Middleware<State>...) {
        self.init(middlewares)
    }

    public func attachTo(_ container: AnyStateContainer<State>) {
        middlewares.forEach {
            $0.attachTo(container)
        }
    }

    public func respond(to mutation: any Mutation<State>, forwardingTo next: Dispatch<State>) {
        var current: (any Mutation<State>)! = mutation

        for middleware in middlewares.reversed() {
            guard let mutation = current else {
                return
            }

            middleware.respond(to: mutation, forwardingTo: { next in
                current = next
            })
        }

        next(current)
    }
}
