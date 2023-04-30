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

    func flatMapAsync<T>(maxPublishers: Subscribers.Demand = .unlimited,
                         priority: TaskPriority? = nil,
                         operation: @escaping @Sendable (Output) async -> T) -> some Publisher<T, Failure> {
        flatMap(maxPublishers: maxPublishers) { output in
            AsyncPublisher(priority: priority, operation: {
                await operation(output)
            })
        }
    }
}
