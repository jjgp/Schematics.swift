import UnidirectionalSchema

// MARK: - Count

struct Count: Equatable {
    var count = 0
}

extension Count {
    struct Add: Action, Equatable {
        let value: Int

        init(_ value: Int) {
            self.value = value
        }
    }
}

func mutation(count: inout Count, action: Action) {
    if let action = action as? Count.Add {
        count.count += action.value
    }
}

// MARK: - Counts

struct Counts: Equatable {
    var first: Count = .init()
    var second: Count = .init()
}

extension Counts {
    struct Add: Action {
        let keyPath: WritableKeyPath<Counts, Count>
        let value: Int

        init(_ value: Int, to keyPath: WritableKeyPath<Counts, Count>) {
            self.keyPath = keyPath
            self.value = value
        }
    }
}

func mutation(counts: inout Counts, action: Action) {
    if let action = action as? Counts.Add {
        counts[keyPath: action.keyPath].count += action.value
    }
}
