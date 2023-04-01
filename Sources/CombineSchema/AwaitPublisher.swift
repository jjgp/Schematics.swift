import Combine

///
public struct AwaitPublisher<Output, Failure: Error>: Combine.Publisher {
    public func receive<S: Subscriber>(subscriber _: S) where S.Input == Output, S.Failure == Failure {
        fatalError()
    }
}

private extension AwaitPublisher {
    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output {
        // TODO: can any of this be reusued?

        func cancel() {
            fatalError()
        }

        func request(_: Subscribers.Demand) {
            fatalError()
        }
    }
}
