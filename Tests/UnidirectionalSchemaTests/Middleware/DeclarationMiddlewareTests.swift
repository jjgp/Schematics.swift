import UnidirectionalSchema
import XCTest

final class DeclarationMiddlewareTests: XCTestCase {
    func testDeclarationMiddlewareInCountStore() {
        @DeclarationBuilder var declarations: any Declaration<Count> {
            Take(Count.Add.self)
            Put(Count.Add(10))
            Select { state in
                Put(Count.Add(state.count + 10))
            }
        }
    }
}

public protocol Declaration<State> {
    associatedtype State
}

@resultBuilder
public enum DeclarationBuilder {
    static func buildBlock<State>(_: any Declaration<State>...) -> any Declaration<State> {
        fatalError()
    }
}

public struct Put<State>: Declaration {
    public init(_: any Mutation<State>) {}
}

public struct Select<State>: Declaration {
    public init(@DeclarationBuilder _: (State) -> any Declaration<State>) {}
}

public struct Take<State>: Declaration {
    public init<M: Mutation>(_: M.Type) where M.State == State {}
}
