import Combine

public extension Publisher {
    // TODO: need to handle task cancellation / combine cancellation

    func await<T>(priority _: TaskPriority? = nil, operation _: @escaping (Output) async -> T) -> Future<T, Never> {
//        flatMap {
//            Future(priority: priority, operation: operation)
//        }
        fatalError()
    }

    func tryAwait<T>(priority _: TaskPriority? = nil, operation _: @escaping (Output) async throws -> T) -> Future<T, Error> {
//        Future(priority: priority, operation: operation)
        fatalError()
    }
}
