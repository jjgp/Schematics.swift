import Combine

public protocol Effect<State> {
    associatedtype State

    func run(
        mutationPublisher: AnyPublisher<any Mutation<State>, Never>,
        statePublisher: AnyPublisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never>

    func run(mutationPublisher: AnyPublisher<any Mutation<State>, Never>) -> any Publisher<any Mutation<State>, Never>
}

public extension Effect {
    func run(
        mutationPublisher: AnyPublisher<any Mutation<State>, Never>,
        statePublisher _: AnyPublisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never> {
        run(mutationPublisher: mutationPublisher)
    }

    func run(
        mutationPublisher _: AnyPublisher<any Mutation<State>, Never>
    ) -> any Publisher<any Mutation<State>, Never> {
        fatalError("Must implement run(mutationPublisher:)")
    }
}

public class EffectMiddleware<State>: Middleware {
    private var container: AnyStateContainer<State>!
    private let mutationPublisher = PassthroughSubject<any Mutation<State>, Never>()
    private let runPublisher: any Publisher<any Mutation<State>, Never>
    private let statePublisher = PassthroughSubject<State, Never>()
    private var subscription: AnyCancellable?

    public init(effect: any Effect<State>) {
        runPublisher = effect.run(
            mutationPublisher: mutationPublisher.eraseToAnyPublisher(),
            statePublisher: statePublisher.eraseToAnyPublisher()
        )
    }

    public func attachTo(_ container: AnyStateContainer<State>) {
        self.container = container

        subscription = runPublisher.sink { mutation in
            container.send(mutation)
        }
    }

    public func respond(
        to mutation: any Mutation<State>,
        forwardingTo next: Dispatch<State>
    ) {
        next(mutation)
        statePublisher.send(container.state)
        mutationPublisher.send(mutation)
    }
}
