///
public protocol Subject<Output>: Publisher {
    ///
    func send(_ value: Output)
}
