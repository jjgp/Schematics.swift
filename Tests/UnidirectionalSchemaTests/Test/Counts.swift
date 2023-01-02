import Combine
import UnidirectionalSchema

// MARK: - Count

struct Count: Equatable {
    var count = 0
}

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

    struct Decrement: Mutation, Effect {
        private let value: Int?

        init() {
            value = nil
        }

        private init(_ value: Int) {
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
                .compactMap { $0 as? Count.Add }
                .map { Self($0.value) }
        }

        typealias State = Count
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

        typealias State = Count
    }
}

// MARK: - Counts

struct Counts: Equatable {
    var first: Count = .init()
    var second: Count = .init()
}

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
}
