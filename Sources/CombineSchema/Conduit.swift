import Combine

///
public protocol Conduit {
    associatedtype Output
    associatedtype Failure: Error

    func receive(completion: Subscribers.Completion<Failure>)
    func receive(_ input: Output)
}

///
public final class AnyConduit<Output, Failure: Error>: Conduit, Hashable {
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    private let receiveInput: (Output) -> Void

    public convenience init<C: Conduit>(_ conduit: C) where C.Output == Output, C.Failure == Failure {
        self.init { completion in
            conduit.receive(completion: completion)
        } receiveInput: { input in
            conduit.receive(input)
        }
    }

    public init(receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
                receiveInput: @escaping (Output) -> Void)
    {
        self.receiveCompletion = receiveCompletion
        self.receiveInput = receiveInput
    }

    public static func == (lhs: AnyConduit<Output, Failure>, rhs: AnyConduit<Output, Failure>) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public func receive(_ input: Output) {
        receiveInput(input)
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
    }
}
