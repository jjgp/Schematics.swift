public struct Thunk<State>: Action {
    let runOnContainer: (AnyStateContainer<State>) -> Void

    public init(_ runOnContainer: @escaping (AnyStateContainer<State>) -> Void) {
        self.runOnContainer = runOnContainer
    }
}

public struct ThunkMiddleware: Middleware {
    public func respond<State>(
        to action: Action,
        sentTo container: AnyStateContainer<State>,
        forwardingTo next: Dispatch
    ) {
        switch action {
        case let action as Thunk<State>:
            action.runOnContainer(container)
        default:
            next(action)
        }
    }
}
