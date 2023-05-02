import Combine
import FoundationSchema

public final class CurrentValueSubject<Output, Failure: Error> {
    private var active: Bool {
        completion == nil
    }

    private var completion: Subscribers.Completion<Failure>?
    private var conduits: Set<Conduit> = []
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
            let conduit = Conduit(subscription)
            conduits.insert(conduit)
            lock.unlock()
            subscriber.receive(subscription: subscription)
        }
    }

    func send(_ value: Output) {
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
    class Conduit: Hashable {
        private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
        private let receiveInput: (Output) -> Void

        init<S: Subscriber>(_ subscription: Subscription<S>) {
            receiveCompletion = subscription.receive(completion:)
            receiveInput = subscription.receive(_:)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }

        func receive(_ input: Output) {
            receiveInput(input)
        }

        func receive(completion: Subscribers.Completion<Failure>) {
            receiveCompletion(completion)
        }

        static func == (lhs: Conduit, rhs: Conduit) -> Bool {
            lhs === rhs
        }
    }

    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var parent: CurrentValueSubject?
        private let lock: UnfairLock = .init()
        private var subscriber: S?

        init(parent: CurrentValueSubject, subscriber: S) {
            self.parent = parent
            self.subscriber = subscriber
        }

        func cancel() {}

        func receive(_: Output) {}

        func receive(completion _: Subscribers.Completion<Failure>) {}

        func request(_: Subscribers.Demand) {}
    }
}
