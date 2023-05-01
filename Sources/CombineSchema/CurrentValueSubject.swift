import Combine
import FoundationSchema

public final class CurrentValueSubject<Output, Failure: Error> {
    private var currentValue: Output
    private let lock: UnfairLock = .init()

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

    public func receive<S>(subscriber _: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        //
    }

    func send(_ value: Output) {
        send { currentValue in
            currentValue = value
        }
    }

    public func send(completion _: Subscribers.Completion<Failure>) {
        //
    }

    public func send(resultOf _: (inout Output) -> Void) {
//        let (value, subscriptions): (Output, Set<Subscription<Value>>) = lock {
//            mutateValue(&currentValue)
//            return (currentValue, self.downstreamSubscriptions)
//        }
    }

    public func send(subscription _: Combine.Subscription) {
        //
    }
}

private extension CurrentValueSubject {
    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var parent: CurrentValueSubject?
        private let lock: UnfairLock = .init()
        private var subscriber: S?

        func cancel() {}

        func request(_: Subscribers.Demand) {}
    }
}
