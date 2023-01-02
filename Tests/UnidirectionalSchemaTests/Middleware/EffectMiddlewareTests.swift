import Combine
import UnidirectionalSchema
import XCTest

final class EffectMiddlewareTests: XCTestCase {
    func testEffectMiddlewareInCountStore() {
        let store = Store(
            middleware: EffectMiddleware(effect: Count.Decrement()),
            state: Count()
        )
        let spy = PublisherSpy(store)

        store.send(Count.Add(10))

        let outputs = spy.outputs.map(\.count)
        XCTAssertEqual(outputs, [0, 10, 0])
    }
}
