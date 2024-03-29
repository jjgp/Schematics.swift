import Combine

///
public protocol Reaction<State> {
    ///
    associatedtype State

    ///
    func run(
        mutationPublisher: some Publisher<any Mutation<State>, Never>,
        statePublisher: some Publisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never>

    ///
    func run(mutationPublisher: some Publisher<any Mutation<State>, Never>) -> any Publisher<any Mutation<State>, Never>
}

///
public extension Reaction {
    ///
    func run(
        mutationPublisher: some Publisher<any Mutation<State>, Never>,
        statePublisher _: some Publisher<State, Never>
    ) -> any Publisher<any Mutation<State>, Never> {
        run(mutationPublisher: mutationPublisher)
    }

    ///
    func run(
        mutationPublisher _: some Publisher<any Mutation<State>, Never>
    ) -> any Publisher<any Mutation<State>, Never> {
        fatalError("Must implement run(mutationPublisher:) in conforming type")
    }
}

///
public class ReactionMiddleware<State>: Middleware {
    private let mutationPublisher = PassthroughSubject<any Mutation<State>, Never>()
    private var runPublisher: any Publisher<any Mutation<State>, Never>
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
        let mutationPublisher = mutationPublisher
        let statePublisher = statePublisher
        runPublisher = Publishers.MergeMany(reactions.map { reaction in
            reaction.run(
                mutationPublisher: mutationPublisher,
                statePublisher: statePublisher
            ).eraseToAnyPublisher()
        })
    }

    ///
    public convenience init(reactions: any Reaction<State>...) {
        self.init(reactions: reactions)
    }

    ///
    public func attach(to container: any StateContainer<State>) {
        subscription = runPublisher.sink { mutation in
            container.send(mutation)
        }
    }

    ///
    public func detach(from _: any StateContainer<State>) {
        subscription = nil
    }

    ///
    public func respond(
        to mutation: any Mutation<State>,
        passedTo container: any StateContainer<State>,
        forwardingTo next: Dispatch<State>
    ) {
        next(mutation)
        statePublisher.send(container.state)
        mutationPublisher.send(mutation)
    }
}

public extension Publisher {
    ///
    func ofScope<State, Substate>(
        state keyPath: WritableKeyPath<State, Substate>
    ) -> Publishers.CompactMap<Self, any Mutation<Substate>> where Output == any Mutation<State> {
        compactMap { mutation in
            guard let scope = mutation as? Mutations.Scope<State, Substate>, scope.keyPath == keyPath else {
                return nil
            }

            return scope.mutation
        }
    }

    ///
    func ofType<M: Mutation>(_: M.Type) -> Publishers.CompactMap<Self, M> where Output == any Mutation<M.State> {
        compactMap {
            $0 as? M
        }
    }

    ///
    func scope<State, Substate>(
        state keyPath: WritableKeyPath<State, Substate>
    ) -> Publishers.Map<Self, any Mutation<State>> where Output == any Mutation<Substate> {
        map {
            Mutations.Scope(mutation: $0, state: keyPath)
        }
    }
}
