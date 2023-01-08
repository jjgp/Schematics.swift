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

        let countsArrayStore = countsStore.scope(state: \.counts)
        countsArrayStore.send(Counts.Push())
        countsArrayStore.send(Counts.Push())

        let firstCountStore = countsStore.scope(state: \.counts[0])
        let firstCountSpy = PublisherSpy(firstCountStore.removeDuplicates())

        let secondCountStore = countsStore.scope(state: \.counts[1])
        let secondCountSpy = PublisherSpy(secondCountStore.removeDuplicates())

        firstCountStore.send(Count.Add(10))
        countsArrayStore.send(Counts.Add(-20, to: \.[0]))
        secondCountStore.send(Count.Add(-20))
        countsArrayStore.send(Counts.Add(40, to: \.[1]))

        let countsOutputs = countsSpy.outputs.map { output in
            guard let first = output.counts.first else {
                return [Int]()
            }

            guard output.counts.count > 1 else {
                return [first.count]
            }

            return [first.count, output.counts[1].count]
        }

        let firstCountOutputs = firstCountSpy.outputs.map(\.count)
        let secondCountOutputs = secondCountSpy.outputs.map(\.count)

        XCTAssertEqual(countsOutputs, [
            [],
            [0],
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
