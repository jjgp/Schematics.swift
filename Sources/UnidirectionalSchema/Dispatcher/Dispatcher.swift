public protocol Dispatcher {
    func receive<State>(mutation: any Mutation<State>, transmitTo dispatch: @escaping Dispatch<State>)
}
