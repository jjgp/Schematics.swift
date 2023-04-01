import UnidirectionalSchema

public final class MiddlewareSpy<State>: Middleware {
    public var onAttach: ((any StateContainer<State>) -> Void)?
    public var onDetach: ((any StateContainer<State>) -> Void)?
    public var onRespond: ((any Mutation<State>, any StateContainer<State>, Dispatch<State>) -> Void)?

    public func attach(to container: any StateContainer<State>) {
        onAttach?(container)
    }

    public func detach(from container: any StateContainer<State>) {
        onDetach?(container)
    }

    public func respond(
        to mutation: any Mutation<State>,
        passedTo container: any StateContainer<State>,
        forwardingTo next: Dispatch<State>
    ) {
        onRespond?(mutation, container, next)
    }
}
