public struct ThunkMiddleware: Middleware {
    public func respond<State>(to action: Action, sentTo container: AnyStateContainer<State>, forwardingTo next: Dispatch) {
        switch action {
        case let action as Thunk<State>:
            action.run(with: container)
        default:
            next(action)
        }
    }
}
