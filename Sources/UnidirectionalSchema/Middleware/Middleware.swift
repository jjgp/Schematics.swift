///
public protocol Middleware<State> {
    ///
    associatedtype State

    ///
    func prepare(for container: any StateContainer<State>)

    ///
    func respond(
        to mutation: any Mutation<State>,
        passedTo container: any StateContainer<State>,
        forwardingTo next: Dispatch<State>
    )
}

public extension Middleware {
    ///
    func prepare(for _: any StateContainer<State>) {}
}
