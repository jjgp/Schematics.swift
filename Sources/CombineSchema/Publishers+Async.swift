import Combine

public extension Publisher {
    func mapAsync<T>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (Output) async -> T
    ) -> Publishers.SwitchToLatest<AsyncPublisher<T>, Publishers.Map<Self, AsyncPublisher<T>>> {
        map { output in
            AsyncPublisher(priority: priority) {
                await operation(output)
            }
        }
        .switchToLatest()
    }

    func mapAsync<T>(
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (Output) async throws -> T,
        mapError: @escaping (any Error) -> Failure
    ) -> Publishers.SwitchToLatest<AsyncThrowingPublisher<T, Failure>, Publishers.Map<Self, AsyncThrowingPublisher<T, Failure>>> {
        map { output in
            AsyncThrowingPublisher(priority: priority,
                                   operation: {
                                       try await operation(output)
                                   },
                                   mapError: mapError)
        }
        .switchToLatest()
    }

    func flatMapAsync<T>(
        maxPublishers: Subscribers.Demand = .unlimited,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (Output) async -> T
    ) -> Publishers.FlatMap<Publishers.SetFailureType<AsyncPublisher<T>, Failure>, Self> {
        flatMap(maxPublishers: maxPublishers) { output in
            AsyncPublisher(priority: priority) {
                await operation(output)
            }
        }
    }
}
