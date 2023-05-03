import Combine
import Foundation
import FoundationSchema

public final class CurrentValueSubject<Output, Failure: Error> {
    private var active: Bool {
        completion == nil
    }

    private var completion: Subscribers.Completion<Failure>?
    private var conduits: Set<Conduit<Output, Failure>> = []
    private var currentValue: Output
    private let lock: UnfairLock = .init()
    private var upstreamSubscribers = [Combine.Subscription]()

    ///
    public var value: Output {
        get {
            lock {
                currentValue
            }
        }
        set {
            send(newValue)
        }
    }

    public init(_ value: Output) {
        currentValue = value
    }

    deinit {
        for upstreamSubscriber in upstreamSubscribers {
            upstreamSubscriber.cancel()
        }
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        lock.lock()
        if let completion {
            lock.unlock()
            subscriber.receive(subscription: Subscriptions.empty)
            subscriber.receive(completion: completion)
        } else {
            let subscription = Subscription(parent: self, subscriber: subscriber)
            conduits.insert(subscription)
            lock.unlock()
            subscriber.receive(subscription: subscription)
        }
    }

    private func remove(_ conduit: Conduit<Output, Failure>) {
        lock.lock()
        guard active else {
            lock.unlock()
            return
        }
        conduits.remove(conduit)
        lock.unlock()
    }

    public func send(_ value: Output) {
        send { currentValue in
            currentValue = value
        }
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        lock.lock()
        guard active else {
            lock.unlock()
            return
        }
        self.completion = completion
        let conduits = conduits
        lock.unlock()

        for conduit in conduits {
            conduit.receive(completion: completion)
        }
    }

    public func send(resultOf mutation: (inout Output) -> Void) {
        lock.lock()
        guard active else {
            lock.unlock()
            return
        }
        let conduits = conduits
        mutation(&currentValue)
        let newValue = currentValue
        lock.unlock()

        for conduit in conduits {
            conduit.receive(newValue)
        }
    }

    public func send(subscription: Combine.Subscription) {
        lock {
            upstreamSubscribers.append(subscription)
        }

        subscription.request(.unlimited)
    }
}

private extension CurrentValueSubject {
    class Subscription<S: Subscriber>: Conduit<Output, Failure>, Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var demand: Subscribers.Demand = .none
        private let lock: UnfairLock = .init()
        private var parent: CurrentValueSubject?
        private let recursiveLock: NSRecursiveLock = .init()
        private var subscriber: S?

        init(parent: CurrentValueSubject, subscriber: S) {
            self.parent = parent
            self.subscriber = subscriber
        }

        func cancel() {
            lock.lock()
            guard let parent else {
                lock.unlock()
                return
            }
            self.parent = nil
            subscriber = nil
            lock.unlock()

            parent.remove(self)
        }

        override func receive(_ input: Output) {
            lock.lock()
            guard demand > 0, let subscriber else {
//                deliveredCurrentValue = false
                lock.unlock()
                return
            }
            demand -= 1
//            deliveredCurrentValue = true
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

        override func receive(completion: Subscribers.Completion<Failure>) {
            lock.lock()
            guard let subscriber else {
                lock.unlock()
                return
            }
            let parent = parent
            self.parent = nil
            self.subscriber = nil
            lock.unlock()

            parent?.remove(self)
            recursiveLock.lock()
            subscriber.receive(completion: completion)
            recursiveLock.unlock()
        }

        func request(_ demand: Subscribers.Demand) {
            demand.guardDemandIsNatural()

            lock.lock()
            guard let subscriber else {
                lock.unlock()
                return
            }

            print(subscriber)
        }
    }
}
