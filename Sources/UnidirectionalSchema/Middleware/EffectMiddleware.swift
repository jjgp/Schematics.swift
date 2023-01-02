import Combine

public protocol Effect<State> {
    associatedtype State

    func run(
        mutationPublisher: AnyPublisher<any Mutation<State>, Never>,
        statePublisher: AnyPublisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never>
}

public extension Effect {
    func run(
        mutationPublisher: AnyPublisher<any Mutation<State>, Never>,
        statePublisher _: AnyPublisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never> {
        run(mutationPublisher: mutationPublisher)
    }

    func run(mutationPublisher _: AnyPublisher<any Mutation<State>, Never>) -> any Publisher<any Mutation<State>, Never> {
        fatalError("Must implement run(mutationPublisher:)")
    }
}

public struct EffectMiddleware<State>: Middleware {
    private let mutationPublisher = PassthroughSubject<any Mutation<State>, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let statePublisher = PassthroughSubject<State, Never>()

    private init() {}

    public func respond(
        to mutation: any Mutation<State>,
        sentTo container: AnyStateContainer<State>,
        forwardingTo next: Dispatch<State>
    ) {
        next(mutation)
        statePublisher.send(container.state)
        mutationPublisher.send(mutation)
    }

    private typealias EffectState = State
}
