import Combine
import Foundation
import FoundationSchema

///
public final class AsyncThrowingPublisher<Output>: Publisher {
    private let operation: @Sendable () async throws -> Output
    private let priority: TaskPriority?

    public init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Output) {
        self.operation = operation
        self.priority = priority
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(parent: self, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }

    public typealias Failure = Error
}

private extension AsyncThrowingPublisher {
    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var parent: AsyncThrowingPublisher?
        private let lock: UnfairLock = .init()
        private var subscriber: S?
        private var task: Task<Void, Never>?

        init(parent: AsyncThrowingPublisher, subscriber: S) {
            self.parent = parent
            self.subscriber = subscriber
        }

        func cancel() {
            lock {
                parent = nil
                subscriber = nil
                task?.cancel()
            }
        }

        func receive(_ input: Output) {
            lock.lock()
            guard parent != nil, let subscriber else {
                lock.unlock()
                return
            }

            parent = nil
            self.subscriber = nil
            lock.unlock()

            _ = subscriber.receive(input)
            subscriber.receive(completion: .finished)
        }

        func receive(error: Failure) {
            lock.lock()
            guard parent != nil, let subscriber else {
                lock.unlock()
                return
            }

            parent = nil
            self.subscriber = nil
            lock.unlock()

            subscriber.receive(completion: .failure(error))
        }

        func request(_ demand: Subscribers.Demand) {
            demand.guardDemandIsNatural()

            lock.lock()
            guard let parent else {
                lock.unlock()
                return
            }

            if task == nil {
                task = Task(priority: parent.priority) { [weak parent, weak self] in
                    guard let operation = parent?.operation else {
                        return
                    }

                    do {
                        self?.receive(try await operation())
                    } catch {
                        self?.receive(error: error)
                    }
                }
            }
            lock.unlock()
        }
    }
}
