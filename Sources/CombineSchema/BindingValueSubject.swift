import Combine
import FoundationSchema

public final class BindingValueSubject<Output, Failure: Error> {
    private let binding: Binding<Output>
    private let lock: UnfairLock = .init()

    public init(_ value: Output) {
        var currentValue = value
        binding = Binding {
            currentValue
        } setValue: { newValue in
            currentValue = newValue
        }
    }

    public init(binding: Binding<Output>) {
        self.binding = binding
    }

    public func scope<T>(value keyPath: WritableKeyPath<Output, T>) -> BindingValueSubject<T, Failure> {
        .init(binding: binding.scope(value: keyPath))
    }
}

private extension BindingValueSubject {
    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var parent: BindingValueSubject?
        private let lock: UnfairLock = .init()
        private var subscriber: S?

        func cancel() {}

        func request(_: Subscribers.Demand) {}
    }
}
