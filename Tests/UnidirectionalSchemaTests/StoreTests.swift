import Combine
import ReactiveSchema
import UnidirectionalSchema
import XCTest

final class StoreTests: XCTestCase {
    func testActionsOnCountStore() {
        let store = Store(state: Count())
        let spy = PublisherSpy(store)

        store.send(Count.Add(10))
        store.send(Count.Add(-20))

        let outputs = spy.outputs.map(\.count)
        XCTAssertEqual(outputs, [0, 10, -10])
    }

    func testMultipleStoresInScope() {
        let countsStore = Store(state: Counts())
        let countsSpy = PublisherSpy(countsStore)
        let firstCountStore = countsStore.scope(state: \.first)
        let firstCountSpy = PublisherSpy(firstCountStore.removeDuplicates())
        let secondCountStore = countsStore.scope(state: \.second)
        let secondCountSpy = PublisherSpy(secondCountStore.removeDuplicates())

        firstCountStore.send(Count.Add(10))
        countsStore.send(Counts.Add(-20, to: \.first))
        secondCountStore.send(Count.Add(-20))
        countsStore.send(Counts.Add(40, to: \.second))

        let countsOutputs = countsSpy.outputs.map { [$0.first.count, $0.second.count] }
        let firstCountOutputs = firstCountSpy.outputs.map(\.count)
        let secondCountOutputs = secondCountSpy.outputs.map(\.count)
        XCTAssertEqual(countsOutputs, [
            [0, 0],
            [10, 0],
            [-10, 0],
            [-10, -20],
            [-10, 20],
        ])
        XCTAssertEqual(firstCountOutputs, [0, 10, -10])
        XCTAssertEqual(secondCountOutputs, [0, -20, 20])
    }
}
