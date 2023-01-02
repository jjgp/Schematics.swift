public protocol Middleware {
    func respond<State>(
        to mutation: any Mutation<State>,
        sentTo container: AnyStateContainer<State>,
        forwardingTo next: Dispatch<State>
    )
}
