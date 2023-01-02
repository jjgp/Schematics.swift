public protocol Thunk<State>: Mutation {
    func run(_ container: AnyStateContainer<State>)
}

public extension Thunk {
    func mutate(state _: inout State) {}
}

public class ThunkMiddleware<State>: Middleware {
    private var container: AnyStateContainer<State>!

    public init() {}

    public func attachTo(_ container: AnyStateContainer<State>) {
        self.container = container
    }

    public func respond(to mutation: any Mutation<State>, forwardingTo next: Dispatch<State>) {
        if let mutation = mutation as? any Thunk<State> {
            mutation.run(container)
        } else {
            next(mutation)
        }
    }
}
