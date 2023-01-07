import Combine
import UnidirectionalSchema

// MARK: - Count

struct Count: Equatable {
    var count = 0
}

// MARK: - Count Mutations

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
            mutationPublisher: AnyPublisher<any Mutation<Count>, Never>
        ) -> any Publisher<any Mutation<Count>, Never> {
            mutationPublisher
                .ofType(Count.Add.self)
                .map { Self($0.value) }
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

// MARK: - Counts

struct Counts: Equatable {
    var first: Count = .init()
    var second: Count = .init()
}

// MARK: - Counts Mutations

extension Counts {
    struct Add: Mutation {
        let keyPath: WritableKeyPath<Counts, Count>
        let value: Int

        init(_ value: Int, to keyPath: WritableKeyPath<Counts, Count>) {
            self.keyPath = keyPath
            self.value = value
        }

        func mutate(state: inout Counts) {
            state[keyPath: keyPath].count += value
        }
    }

    struct Decrement: Mutation, Reaction {
        let keyPath: WritableKeyPath<Counts, Count>?
        let value: Int?

        init(_ value: Int? = nil, to keyPath: WritableKeyPath<Counts, Count>? = nil) {
            self.keyPath = keyPath
            self.value = value
        }

        func mutate(state: inout Counts) {
            if let keyPath, let value {
                state[keyPath: keyPath].count -= value
            }
        }

        func run(
            mutationPublisher: AnyPublisher<any Mutation<Counts>, Never>
        ) -> any Publisher<any Mutation<Counts>, Never> {
            mutationPublisher
                .ofType(Mutations.Scope<Counts, Count>.self)
                .compactMap { scope in
                    guard let add = scope.mutation as? Count.Add else {
                        return nil
                    }

                    return (add.value, scope.keyPath)
                }
                .map(Self.init(_:to:))
        }
    }
}
