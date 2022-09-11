public protocol Middleware {
    func respond<State>(to action: Action, sentTo container: AnyStateContainer<State>, forwardingTo next: Dispatch)
}
