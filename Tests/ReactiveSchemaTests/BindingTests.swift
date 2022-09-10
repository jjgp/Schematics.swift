import ReactiveSchema
import XCTest

class BindingTests: XCTestCase {
    func testBindingAfterScope() {
        var value = State()
        let binding = Binding {
            value
        } setValue: { newValue in
            value = newValue
        }
        let scoped = binding.scope(value: \.nestedState)

        scoped.wrappedValue.count += 1

        let expectedValue = State(nestedState: .init(count: 1))
        XCTAssertEqual(value, expectedValue)
        XCTAssertEqual(binding.wrappedValue, expectedValue)
        XCTAssertEqual(scoped.wrappedValue, expectedValue.nestedState)
    }

    struct State: Equatable {
        struct NestedState: Equatable {
            var count = 0
        }

        var nestedState = NestedState()
    }
}
