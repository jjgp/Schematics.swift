///
public protocol Mutation<State> {
    ///
    associatedtype State

    ///
    func mutate(state: inout State)
}

///
public enum Mutations {
    ///
    public struct Scope<State, Substate>: Mutation {
        ///
        public let keyPath: WritableKeyPath<State, Substate>
        ///
        public let mutation: any Mutation<Substate>

        init(mutation: any Mutation<Substate>, state keyPath: WritableKeyPath<State, Substate>) {
            self.keyPath = keyPath
            self.mutation = mutation
        }

        ///
        public func mutate(state: inout State) {
            mutation.mutate(state: &state[keyPath: keyPath])
        }
    }
}
