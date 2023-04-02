import Combine
import Foundation
import FoundationSchema

///
public struct BridgedPublisher<Output>: Combine.Publisher {
    // TODO: may be able to use publisher directly
    private let subscribeReceiveValue: (@escaping (Output) -> Void) -> Cancellable

    init<P: Publisher>(_ publisher: P) where P.Output == Output {
        subscribeReceiveValue = publisher.subscribe(receiveValue:)
    }

    ///
    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = Subscription(subscriber: subscriber, subscribeReceiveValue: subscribeReceiveValue)
        subscriber.receive(subscription: subscription)
    }

    ///
    public typealias Failure = Never
}

public extension Publisher {
    ///
    func bridged() -> BridgedPublisher<Output> {
        .init(self)
    }
}

private extension BridgedPublisher {
    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output {
        private var demand: Subscribers.Demand = .none
        private let lock: UnfairLock = .init()
        private let recursiveLock: NSRecursiveLock = .init()
        private var subscriber: S?
        private let subscribeReceiveValue: (@escaping (Output) -> Void) -> Cancellable
        private var subscription: Cancellable?

        init(subscriber: S, subscribeReceiveValue: @escaping (@escaping (Output) -> Void) -> Cancellable) {
            self.subscriber = subscriber
            self.subscribeReceiveValue = subscribeReceiveValue
        }

        func cancel() {
            lock {
                subscription?.cancel()
                subscription = nil
                subscriber = nil
            }
        }

        func receive(_ input: Output) {
            lock.lock()
            guard demand > 0, let subscriber else {
                lock.unlock()
                return
            }
            demand -= 1
            lock.unlock()

            recursiveLock.lock()
            let additionalDemand = subscriber.receive(input)
            recursiveLock.unlock()

            if additionalDemand > 0 {
                lock {
                    self.demand += additionalDemand
                }
            }
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                fatalError("Demand must be greater than none")
            }

            lock {
                guard subscriber != nil else {
                    return
                }

                self.demand += demand

                if subscription == nil {
                    subscription = subscribeReceiveValue { [weak self] value in
                        self?.receive(value)
                    }
                }
            }
        }
    }
}
