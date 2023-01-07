import Combine

///
public protocol Reaction<State> {
    ///
    associatedtype State

    ///
    func run(
        mutationPublisher: AnyPublisher<any Mutation<State>, Never>,
        statePublisher: AnyPublisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never>

    ///
    func run(mutationPublisher: AnyPublisher<any Mutation<State>, Never>) -> any Publisher<any Mutation<State>, Never>
}

///
public extension Reaction {
    ///
    func run(
        mutationPublisher: AnyPublisher<any Mutation<State>, Never>,
        statePublisher _: AnyPublisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never> {
        run(mutationPublisher: mutationPublisher)
    }

    ///
    func run(
        mutationPublisher _: AnyPublisher<any Mutation<State>, Never>
    ) -> any Publisher<any Mutation<State>, Never> {
        fatalError("Must implement run(mutationPublisher:)")
    }
}

///
public class ReactionMiddleware<State>: Middleware {
    private var container: AnyStateContainer<State>!
    private let mutationPublisher = PassthroughSubject<any Mutation<State>, Never>()
    private var runPublisher: (any Publisher<any Mutation<State>, Never>)!
    private let statePublisher = PassthroughSubject<State, Never>()
    private var subscription: AnyCancellable?

    ///
    public init(reaction: any Reaction<State>) {
        runPublisher = reaction.run(
            mutationPublisher: mutationPublisher.eraseToAnyPublisher(),
            statePublisher: statePublisher.eraseToAnyPublisher()
        )
    }

    ///
    public init(reactions: [any Reaction<State>]) {
        runPublisher = Publishers.MergeMany(reactions.map { reaction in
            reaction.run(
                mutationPublisher: mutationPublisher.eraseToAnyPublisher(),
                statePublisher: statePublisher.eraseToAnyPublisher()
            ).eraseToAnyPublisher()
        })
    }

    ///
    public convenience init(reactions: any Reaction<State>...) {
        self.init(reactions: reactions)
    }

    ///
    public func attachTo(_ container: AnyStateContainer<State>) {
        self.container = container

        subscription = runPublisher.sink { mutation in
            container.send(mutation)
        }
    }

    ///
    public func respond(
        to mutation: any Mutation<State>,
        forwardingTo next: Dispatch<State>
    ) {
        next(mutation)
        statePublisher.send(container.state)
        mutationPublisher.send(mutation)
    }
}

public extension Publisher {
    func ofType<M: Mutation>(_: M.Type) -> Publishers.CompactMap<Self, M> where Output == any Mutation<M.State> {
        compactMap {
            $0 as? M
        }
    }
}
