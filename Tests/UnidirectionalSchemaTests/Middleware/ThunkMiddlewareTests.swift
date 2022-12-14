import Combine
import UnidirectionalSchema
import XCTest

final class ThunkMiddlewareTests: XCTestCase {
    func testOutputStateAfterThunksSentThroughStore() {
        // Given a store of Count with thunk middleware
        let store = Store(
            middleware: ThunkMiddleware(),
            state: Count()
        )
        let spy = PublisherSpy(store)

        store.send(Count.Add(10))
        store.send(Count.Multiply(10))

        let outputs = spy.outputs.map(\.count)
        XCTAssertEqual(outputs, [0, 10, 100])
    }
}
