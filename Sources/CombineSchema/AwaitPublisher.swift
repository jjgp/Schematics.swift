import Combine
import Foundation
import FoundationSchema

///
public struct AwaitPublisher<Output, Failure: Error>: Combine.Publisher {
    private let lock: UnfairLock = .init()
    private let operation: @Sendable () async -> Output
    private let priority: TaskPriority?
    private var result: Result<Output, Failure>?
    private var task: Task<Output, Failure>?

    public init(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> Output) {
        self.operation = operation
        self.priority = priority
    }

    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = lock {
            // TODO: if completed use
            AsyncSubscription(publisher: self, subscriber: subscriber)
        }
        subscriber.receive(subscription: subscription)
    }

    // TODO: method to forward result and method to dissasciate
}

private extension AwaitPublisher {
    // TODO: there still may be a case where the AsyncSubscription is not requested until after the task completes with result
    class CompletedSubscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var active = true
        private let lock: UnfairLock = .init()
        private let result: Result<Output, Failure>
        private var subscriber: S?

        init(result: Result<Output, Failure>, subscriber: S) {
            self.result = result
            self.subscriber = subscriber
        }

        func cancel() {
            lock {
                active = false
                subscriber = nil
            }
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

            switch result {
            case let .success(output):
                _ = subscriber.receive(output)
                subscriber.receive(completion: .finished)
            case let .failure(error):
                subscriber.receive(completion: .failure(error))
            }
        }
    }

    class AsyncSubscription<S: Subscriber>: Combine.Subscription where S.Input == Output {
        private var active = true
        private let lock: UnfairLock = .init()
        private var publisher: AwaitPublisher?
        private var subscriber: S?

        init(publisher _: AwaitPublisher, subscriber: S) {
            self.subscriber = subscriber
        }

        func cancel() {
            lock {
                _ = publisher
                self.publisher = nil
                // publisher?.disassociate(self)
                subscriber = nil
            }
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
            // TODO: get parent

            // TODO: publisher?.disassociate(self)
        }

        func request(_ demand: Subscribers.Demand) {
            demand.guardDemandIsNatural()

            lock.lock()
            guard subscriber != nil else {
                lock.unlock()
                return
            }

//            self.demand += demand

//            if let publisher, let _ = publisher.result {
//                self.demand = .none
//                lock.unlock()
            /*
             downstreamLock.lock()
             lockedFulfill(downstream: downstream, result: result)
             downstreamLock.unlock()
             parent.disassociate(self)
             */
//            } else {
//                lock.unlock()
//            }
        }
    }
}
