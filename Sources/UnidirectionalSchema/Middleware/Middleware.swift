public protocol Middleware<State> {
    associatedtype State

    func attachTo(_ container: AnyStateContainer<State>)

    func respond(
        to mutation: any Mutation<State>,
        forwardingTo next: Dispatch<State>
    )
}

public extension Middleware {
    func attachTo(_: AnyStateContainer<State>) {}
}
