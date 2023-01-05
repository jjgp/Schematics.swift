import UnidirectionalSchema
import XCTest

final class DeclarationMiddlewareTests: XCTestCase {
    func testDeclarationMiddlewareInCountStore() {
        @DeclarationBuilder var declarations: some Declaration<Count> {
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
    static func buildBlock<State>(_: any Declaration<State>...) -> Block<State> {
        .init()
    }
}

public struct Block<State>: Declaration {}

public struct Put<State>: Declaration {
    public init(_: any Mutation<State>) {}
}

public struct Select<State>: Declaration {
    public init(@DeclarationBuilder _: (State) -> any Declaration<State>) {}
}

public struct Take<State>: Declaration {
    public init<M: Mutation>(_: M.Type) where M.State == State {}
}
