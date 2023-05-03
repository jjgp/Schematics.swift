import Combine
import FoundationSchema

///
public final class AsyncPublisher<Output>: Publisher {
    private let operation: @Sendable () async -> Output
    private let priority: TaskPriority?

    public init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Output) {
        self.operation = operation
        self.priority = priority
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(parent: self, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }

    public typealias Failure = Never
}

private extension AsyncPublisher {
    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var parent: AsyncPublisher?
        private let lock: UnfairLock = .init()
        private var subscriber: S?
        private var task: Task<Void, Never>?

        init(parent: AsyncPublisher, subscriber: S) {
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

                    self?.receive(await operation())
                }
            }
            lock.unlock()
        }
    }
}
