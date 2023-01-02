import Combine

public final class Cancellable: Combine.Cancellable, Hashable {
    private(set) var execute: Cancel?

    public init(_ cancel: @escaping Cancel) {
        execute = cancel
    }

    deinit {
        execute?()
    }

    public func cancel() {
        execute?()
        execute = nil
    }

    public typealias Cancel = () -> Void
}

public extension Cancellable {
    static func == (lhs: Cancellable, rhs: Cancellable) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
