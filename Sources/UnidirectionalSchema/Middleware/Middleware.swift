///
public protocol Middleware<State> {
    ///
    associatedtype State

    ///
    func attachTo(_ container: any StateContainer<State>)

    ///
    func respond(
        to mutation: any Mutation<State>,
        forwardingTo next: Dispatch<State>
    )
}

public extension Middleware {
    ///
    func attachTo(_: any StateContainer<State>) {}
}
