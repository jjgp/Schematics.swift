///
public protocol Thunk<State> {
    associatedtype State

    ///
    func run(_ container: any StateContainer<State>)
}

///
public class ThunkMiddleware<State>: Middleware {
    ///
    public init() {}

    ///
    public func respond(
        to mutation: any Mutation<State>,
        passedTo container: any StateContainer<State>,
        forwardingTo next: Dispatch<State>
    ) {
        if let thunk = (mutation as? Mutations.AnyThunk<State>)?.thunk {
            thunk.run(container)
        } else {
            next(mutation)
        }
    }
}

public extension Store {
    func send(_ thunk: any Thunk<State>) {
        send(Mutations.AnyThunk(thunk))
    }
}

public extension Mutations {
    ///
    struct AnyThunk<State>: Mutation {
        ///
        public let thunk: any Thunk<State>

        init(_ thunk: any Thunk<State>) {
            self.thunk = thunk
        }

        ///
        public func mutate(state _: inout State) {}
    }
}
