import Combine

class Conduit<Output, Failure: Error>: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    func receive(_: Output) {}

    func receive(completion _: Subscribers.Completion<Failure>) {}

    static func == (lhs: Conduit, rhs: Conduit) -> Bool {
        lhs === rhs
    }
}
