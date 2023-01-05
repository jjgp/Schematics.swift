///
public protocol Publisher<Output> {
    ///
    associatedtype Output

    ///
    func subscribe(receiveValue: @escaping (Output) -> Void) -> Cancellable
}
