///
public protocol Thunk<State> {
    associatedtype State

    ///
    func run(_ container: any StateContainer<State>)
}

///
public class ThunkMiddleware<State>: Middleware {
    private var container: (any StateContainer<State>)!

    ///
    public init() {}

    ///
    public func attachTo(_ container: any StateContainer<State>) {
        self.container = container
    }

    ///
    public func respond(to mutation: any Mutation<State>, forwardingTo next: Dispatch<State>) {
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
