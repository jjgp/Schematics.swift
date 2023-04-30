import Combine

public extension Publisher {
    func mapAsync<T>(priority: TaskPriority? = nil,
                     operation: @escaping @Sendable (Output) async -> T) -> some Publisher<T, Failure> {
        map { output in
            AsyncPublisher(priority: priority, operation: {
                await operation(output)
            })
        }
        .switchToLatest()
    }

    func tryMapAsync<T>(priority: TaskPriority? = nil,
                        operation: @escaping @Sendable (Output) async throws -> T) -> some Publisher<T, Error> {
        mapError {
            $0 as Error // TODO: not sure about this
        }
        .map { output in
            AsyncThrowingPublisher(priority: priority, operation: {
                try await operation(output)
            })
        }
        .switchToLatest()
    }

    func flatMapAsync<T>(maxPublishers: Subscribers.Demand = .unlimited,
                         priority: TaskPriority? = nil,
                         operation: @escaping @Sendable (Output) async -> T) -> some Publisher<T, Failure> {
        flatMap(maxPublishers: maxPublishers) { output in
            AsyncPublisher(priority: priority, operation: {
                await operation(output)
            })
        }
    }

    func flatMapAsync<T>(maxPublishers: Subscribers.Demand = .unlimited,
                         priority: TaskPriority? = nil,
                         operation: @escaping @Sendable (Output) async throws -> T) -> some Publisher<T, Error> {
        mapError {
            $0 as Error // TODO: not sure about this
        }
        .flatMap(maxPublishers: maxPublishers) { output in
            AsyncThrowingPublisher(priority: priority, operation: {
                try await operation(output)
            })
        }
    }
}
