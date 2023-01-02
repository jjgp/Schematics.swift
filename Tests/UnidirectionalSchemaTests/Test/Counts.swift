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
