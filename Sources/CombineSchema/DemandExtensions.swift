import Combine

public extension Subscribers.Demand {
    ///
    @inlinable
    func guardDemandIsNatural() {
        guard self > 0 else {
            fatalError("Demand must be greater than none")
        }
    }
}
