///
public protocol Middleware<State> {
    ///
    associatedtype State

    ///
    func attach(to container: any StateContainer<State>)

    ///
    func detach(from container: any StateContainer<State>)

    ///
    func respond(
        to mutation: any Mutation<State>,
        passedTo container: any StateContainer<State>,
        forwardingTo next: Dispatch<State>
    )
}

public extension Middleware {
    ///
    func attach(to _: any StateContainer<State>) {}

    ///
    func detach(from _: any StateContainer<State>) {}
}
