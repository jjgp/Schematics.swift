public protocol Middleware {
    func respond<State>(to _: Action, sentTo _: AnyStateContainer<State>, forwardingTo _: Dispatch)
}
