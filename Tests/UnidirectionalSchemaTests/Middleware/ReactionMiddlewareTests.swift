import Combine
import UnidirectionalSchema
import XCTest

final class ReactionMiddlewareTests: XCTestCase {
    func testReactionMiddlewareInCountStore() {
        let store = Store(
            middleware: ReactionMiddleware(reaction: Count.Decrement()),
            state: Count()
        )
        let spy = PublisherSpy(store)

        store.send(Count.Add(10))

        let outputs = spy.outputs.map(\.count)
        XCTAssertEqual(outputs, [0, 10, 0])
    }

    func testMultipleReactionMiddlewareInCountStore() {
        let store = Store(
            middleware: ReactionMiddleware(reactions: Count.Decrement(), Count.Decrement()),
            state: Count()
        )
        let spy = PublisherSpy(store)

        store.send(Count.Add(10))

        let outputs = spy.outputs.map(\.count)
        XCTAssertEqual(outputs, [0, 10, 0, -10])
    }
}
