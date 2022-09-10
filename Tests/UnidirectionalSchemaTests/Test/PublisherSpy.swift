import ReactiveSchema

public final class PublisherSpy<Input> {
    private var cancellable: Cancellable!
    public private(set) var outputs: [Input] = []

    public init<P: Publisher>(_ publisher: P) where P.Output == Input {
        cancellable = publisher.subscribe { [weak self] value in
            self?.outputs.append(value)
        }
    }

    deinit {
        cancellable.cancel()
    }

    public func cancel() {
        cancellable.cancel()
    }
}
