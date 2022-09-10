open class Thunk<State>: Action {
    public init() {}

    open func run(on _: AnyStateContainer<State>) {}
}

public struct ThunkMiddleware: Middleware {
    public func respond<State>(to action: Action, sentTo container: AnyStateContainer<State>, forwardingTo next: Dispatch) {
        switch action {
        case let action as Thunk<State>:
            action.run(on: container)
        default:
            next(action)
        }
    }
}
