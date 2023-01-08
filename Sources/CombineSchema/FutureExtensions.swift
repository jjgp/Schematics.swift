import Combine

public extension Future {
    convenience init(priority: TaskPriority? = nil, operation: @escaping () async -> Output) {
        self.init { promise in
            Task(priority: priority) {
                promise(.success(await operation()))
            }
        }
    }

    convenience init(priority: TaskPriority? = nil, operation: @escaping () async throws -> Output) where Failure == Error {
        self.init { promise in
            Task(priority: priority) {
                do {
                    promise(.success(try await operation()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
