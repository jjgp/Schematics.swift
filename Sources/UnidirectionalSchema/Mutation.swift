///
public protocol Mutation<State> {
    ///
    associatedtype State

    ///
    func mutate(state: inout State)
}

///
public enum Mutations {
    // TODO: some way to unscope/flatten the action
    // Need to think more on the telescoping/flattening of the Scope action

    ///
    public struct Scope<State, T>: Mutation {
        ///
        public let keyPath: WritableKeyPath<State, T>
        ///
        public let mutation: any Mutation<T>

        init(mutation: any Mutation<T>, state keyPath: WritableKeyPath<State, T>) {
            self.keyPath = keyPath
            self.mutation = mutation
        }

        ///
        public func mutate(state: inout State) {
            mutation.mutate(state: &state[keyPath: keyPath])
        }
    }
}
