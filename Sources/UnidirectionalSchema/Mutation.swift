///
public protocol Mutation<State> {
    ///
    associatedtype State

    ///
    func mutate(state: inout State)
}
