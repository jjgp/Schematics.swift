import Combine

public extension Publisher {
    func mapAsync<T>(priority: TaskPriority? = nil,
                     operation: @escaping @Sendable (Output) async -> T) -> some Publisher<T, Failure> {
        map { output in
            AsyncPublisher(priority: priority) {
                await operation(output)
            }
        }
        .switchToLatest()
    }

    func mapAsync<T>(priority: TaskPriority? = nil,
                     operation: @escaping @Sendable (Output) async throws -> T) -> some Publisher<T, Failure> {
        map { output in
            AsyncThrowingPublisher(priority: priority) {
                try await operation(output)
            }
        }
        .switchToLatest()
    }

    func mapAsync<T>(priority: TaskPriority? = nil,
                     operation: @escaping @Sendable (Output) async throws -> T,
                     mapError: @escaping (any Error) -> Failure) -> some Publisher<T, Failure> {
        map { output in
            AsyncThrowingPublisher(priority: priority,
                                   operation: {
                                       try await operation(output)
                                   },
                                   mapError: mapError)
        }
        .switchToLatest()
    }

    func flatMapAsync<T>(maxPublishers: Subscribers.Demand = .unlimited,
                         priority: TaskPriority? = nil,
                         operation: @escaping @Sendable (Output) async -> T) -> some Publisher<T, Failure> {
        flatMap(maxPublishers: maxPublishers) { output in
            AsyncPublisher(priority: priority) {
                await operation(output)
            }
        }
    }
}
