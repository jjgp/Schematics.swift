open class Thunk<State>: Action {
    public init() {}

    open func run(with _: AnyStateContainer<State>) {}
}
