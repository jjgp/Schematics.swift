import Combine
import Foundation
import FoundationSchema

///
public final class AsyncPublisher<Output>: Publisher {
//    private var conduits = Set<any Conduit<Output>>()
    private let lock: UnfairLock = .init()
    private let operation: @Sendable () async -> Output
    private let priority: TaskPriority?
    private var output: Output?
    private var task: Task<Void, Failure>?

    public init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Output) {
        self.operation = operation
        self.priority = priority
    }

    private func forward(input _: Output) {
        // TODO: forward input to conduits
    }

    private func produce() -> Output? {
        lock.lock()
        guard output == nil else {
            lock.unlock()
            return output
        }

        if task == nil {
            task = Task(priority: priority) { [weak self] in
                guard let operation = self?.operation else {
                    return
                }

                let output = await operation()
                self?.output = output
                self?.forward(input: output)
            }
        }
        lock.unlock()

        return nil
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(subscriber: subscriber, produce: produce) { _ in
            // TODO: dissassociate
        }

//        conduits.append(subscription)
        subscriber.receive(subscription: subscription)
    }

    // TODO: method to forward result and method to dissasciate
    public typealias Failure = Never
}

private extension AsyncPublisher {
    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var active = true
        private let produce: () -> Output?
        private let lock: UnfairLock = .init()
        // TODO: may need to pass the on cancel separately
        private let onCancel: (Subscription) -> Void
        private var subscriber: S?

        init(subscriber: S,
             produce: @escaping () -> Output?,
             onCancel: @escaping (Subscription) -> Void)
        {
            self.produce = produce
            self.onCancel = onCancel
            self.subscriber = subscriber
        }

        func cancel() {
            lock {
                active = false
                subscriber = nil
            }

            onCancel(self)
        }

        func receive(_ input: Output) {
            lock.lock()
            guard active, let subscriber else {
                lock.unlock()
                return
            }

            active = false
            self.subscriber = nil
            lock.unlock()

            _ = subscriber.receive(input)
            subscriber.receive(completion: .finished)
        }

        func request(_ demand: Subscribers.Demand) {
            demand.guardDemandIsNatural()

            lock.lock()
            guard active, let subscriber else {
                lock.unlock()
                return
            }

            active = false
            self.subscriber = nil
            lock.unlock()

            guard let output = produce() else {
                return
            }

            _ = subscriber.receive(output)
            subscriber.receive(completion: .finished)
        }
    }
}
