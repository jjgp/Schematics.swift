import Combine
import UnidirectionalSchema

// MARK: - Count

struct Count: Equatable {
    var count = 0
}

// MARK: - Counts

struct Counts: Equatable {
    var counts: [Count] = []
}

// MARK: - Mutations

extension Count {
    struct Add: Mutation {
        let value: Int

        init(_ value: Int) {
            self.value = value
        }

        func mutate(state: inout Count) {
            state.count += value
        }
    }

    struct Decrement: Mutation, Reaction {
        let value: Int?

        init(_ value: Int? = nil) {
            self.value = value
        }

        func mutate(state: inout Count) {
            if let value {
                state.count -= value
            }
        }

        func run(
            mutationPublisher: some Publisher<any Mutation<Count>, Never>
        ) -> any Publisher<any Mutation<Count>, Never> {
            mutationPublisher
                .ofType(Count.Add.self)
                .map {
                    Self($0.value)
                }
        }
    }

    struct Multiply: Thunk {
        let multiplier: Int

        init(_ multiplier: Int) {
            self.multiplier = multiplier
        }

        func run(_ container: AnyStateContainer<Count>) {
            let count = container.state.count
            container.send(Add(multiplier * count - count))
        }
    }
}

extension Counts {
    struct Add: Mutation {
        let keyPath: WritableKeyPath<[Count], Count>
        let value: Int

        init(_ value: Int, to keyPath: WritableKeyPath<[Count], Count>) {
            self.keyPath = keyPath
            self.value = value
        }

        func mutate(state: inout [Count]) {
            state[keyPath: keyPath].count += value
        }
    }

    struct Decrement: Mutation {
        let keyPath: WritableKeyPath<[Count], Count>
        let value: Int

        init(_ value: Int, to keyPath: WritableKeyPath<[Count], Count>) {
            self.keyPath = keyPath
            self.value = value
        }

        func mutate(state: inout [Count]) {
            state[keyPath: keyPath].count -= value
        }
    }

    struct Push: Mutation {
        func mutate(state: inout [Count]) {
            state.append(.init())
        }
    }
}

// MARK: - Reactions

extension Counts {
    struct DecrementCounts: Reaction {
        func run(
            mutationPublisher: some Publisher<any Mutation<Counts>, Never>
        ) -> any Publisher<any Mutation<Counts>, Never> {
            mutationPublisher
                .ofScope(state: \.counts)
                .ofType(Mutations.Scope<[Count], Count>.self)
                .compactMap { scope in
                    guard let add = scope.mutation as? Count.Add else {
                        return nil
                    }

                    return (add.value, scope.keyPath)
                }
                .map(Counts.Decrement.init(_:to:))
                .map {
                    Mutations.Scope(mutation: $0, state: \.counts)
                }
        }
    }
}
