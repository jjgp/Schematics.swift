//public struct Thunk<State>: Mutation {
//    let runOnContainer: (AnyStateContainer<State>) -> Void
//
//    public init(_ runOnContainer: @escaping (AnyStateContainer<State>) -> Void) {
//        self.runOnContainer = runOnContainer
//    }
//}
//
//public struct ThunkMiddleware: Middleware {
//    public func respond<State>(
//        to mutation: any Mutation<State>,
//        sentTo container: AnyStateContainer<State>,
//        forwardingTo next: Dispatch<State>
//    ) {
//        switch mutation {
//        case let mutation as Thunk<State>:
//            mutation.runOnContainer(container)
//        default:
//            next(mutation)
//        }
//    }
//}
