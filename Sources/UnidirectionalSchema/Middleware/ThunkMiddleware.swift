public protocol Thunk<State>: Mutation {
    func run(_ container: AnyStateContainer<State>)
}

public extension Thunk {
    func mutate(state _: inout State) {}
}

public struct ThunkMiddleware<State>: Middleware {
    public init() {}

    public func respond(
        to mutation: any Mutation<State>,
        sentTo container: AnyStateContainer<State>,
        forwardingTo next: Dispatch<State>
    ) {
        if let mutation = mutation as? any Thunk<State> {
            mutation.run(container)
        } else {
            next(mutation)
        }
    }
}
