/// A binding that wraps a value. The binding is similar to SwiftUI's `Binding`.
public struct Binding<Value> {
    private let getValue: () -> Value
    private let setValue: (Value) -> Void

    /// The underlying value.
    public var wrappedValue: Value {
        get {
            getValue()
        }
        nonmutating set {
            setValue(newValue)
        }
    }

    /// Initialize the binding with closures that get and set the value.
    ///
    /// - Parameter getValue: A closure that returns the value.
    /// - Parameter setValue: A closure that allows setting the value.
    public init(getValue: @escaping () -> Value, setValue: @escaping (Value) -> Void) {
        self.getValue = getValue
        self.setValue = setValue
    }

    /// Scope the binding to a the resulting value at a key path.
    ///
    /// - Parameter value: A writable key path to the new value of type `T`.
    /// - Returns: A new binding of type `T`.
    public func scope<T>(value keyPath: WritableKeyPath<Value, T>) -> Binding<T> {
        .init {
            wrappedValue[keyPath: keyPath]
        } setValue: { value in
            wrappedValue[keyPath: keyPath] = value
        }
    }
}
