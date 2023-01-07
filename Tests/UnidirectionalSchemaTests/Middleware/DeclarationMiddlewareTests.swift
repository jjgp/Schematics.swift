import SwiftUI
import UnidirectionalSchema
import XCTest

final class DeclarationMiddlewareTests: XCTestCase {
    func testDeclarationMiddlewareInCountStore() {
        @DeclarationBuilder var declarations: some Declaration<Counts> {
            Take(Counts.Add.self) { mutation in
                Put(Counts.Decrement(mutation.value, to: \.first))
            }
            Put(Counts.Add(10, to: \.second))
            Select { state in
                Put(Counts.Add(state.second.count + 10, to: \.first))
            }
            Select(\Counts.first) { state in
                Take(Count.Decrement.self)
                Put(Count.Add(state.count + 10))
            }
        }
    }
}

public protocol Statement {}

public protocol StatementConvertible {}

public struct AnyStatement {}

public protocol Declaration<State>: StatementConvertible {
    associatedtype State
}

@resultBuilder
public enum DeclarationBuilder {
    static func buildBlock<State>(_: any Declaration<State>...) -> Block<State> {
        .init()
    }
}

public struct Block<State>: Declaration {}

public struct Call: Statement {}

public struct Put<State>: Declaration {
    public init(_: any Mutation<State>) {}
}

public struct Select<State>: Declaration {
    public init(@DeclarationBuilder _: (State) -> any Declaration<State>) {}

    init<Substate>(_: WritableKeyPath<State, Substate>, @DeclarationBuilder _: (Substate) -> any Declaration<Substate>) {}
}

public struct Take<State>: Declaration {
    public init<M: Mutation>(_: M.Type) where M.State == State {}

    public init<M: Mutation>(_: M.Type, @DeclarationBuilder _: (M) -> some Declaration<State>) where M.State == State {}
}

// TODO: to support Call the declaration protocol should have a stateless and stateful counterpart
