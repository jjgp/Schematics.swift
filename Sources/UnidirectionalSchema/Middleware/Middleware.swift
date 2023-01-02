public protocol Middleware<State> {
    associatedtype State

    func respond(
        to mutation: any Mutation<State>,
        sentTo container: AnyStateContainer<State>,
        forwardingTo next: Dispatch<State>
    )
}
