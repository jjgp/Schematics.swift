import Combine
import Foundation
import FoundationSchema

///
public final class AsyncPublisher<Output>: Publisher {
    private var conduits = Set<AnyConduit<Output, Failure>>()
    private let conduitsLock: UnfairLock = .init()
    private let operation: @Sendable () async -> Output
    private let priority: TaskPriority?
    private var result: Result<Output, Failure>?
    private let resultLock: UnfairLock = .init()
    private var task: Task<Void, Failure>?

    // TODO: remove conduit list and issue task to subscription instead.

    public init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Output) {
        self.operation = operation
        self.priority = priority
    }

    private func forward(input: Output) {
        conduitsLock.lock()
        let conduits = conduits
        conduitsLock.unlock()

        for conduit in conduits {
            conduit.receive(input)
        }
    }

    private func produce() -> Result<Output, Failure>? {
        resultLock.lock()
        guard result == nil else {
            resultLock.unlock()
            return result
        }

        if task == nil {
            task = Task(priority: priority) { [weak self] in
                guard let operation = self?.operation else {
                    return
                }

                let output = await operation()
                self?.resultLock {
                    self?.result = .success(output)
                }

                self?.forward(input: output)
            }
        }
        resultLock.unlock()

        return nil
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(subscriber: subscriber, produce: produce)

        // TODO: what to do if subscribes when task completes or is cancelled? The current result/conduit pattern doesn't
        // capture this dynamic?

//        let conduit = outputLock.lock {
//            if output == nil {
//                let conduit = AnyConduit(subscription)
//                return conduit
//            }
//
//            return
//        }

        // TODO: if result do not append
        // TODO: conduits.append()
        subscriber.receive(subscription: subscription)
    }

    public typealias Failure = Never
}

private extension AsyncPublisher {
    class Subscription<S: Subscriber>: Conduit, Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var active = true
        private let produce: () -> Result<Output, Failure>?
        private let lock: UnfairLock = .init()
        private var onCancel: (() -> Void)?
        private var subscriber: S?

        init(subscriber: S, produce: @escaping () -> Result<Output, Failure>?) {
            self.produce = produce
            self.subscriber = subscriber
        }

        func cancel() {
            lock {
                active = false
                onCancel?()
                onCancel = nil
                subscriber = nil
            }
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            lock.lock()
            guard active, let subscriber else {
                lock.unlock()
                return
            }

            active = false
            self.subscriber = nil
            lock.unlock()

            subscriber.receive(completion: completion)
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
            guard active else {
                lock.unlock()
                return
            }
            lock.unlock()

            guard case let .success(output) = produce() else {
                return
            }

            receive(output)
        }
    }
}
