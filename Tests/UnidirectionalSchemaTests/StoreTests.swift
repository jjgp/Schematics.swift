import Combine
import ReactiveSchema
import UnidirectionalSchema
import XCTest

final class StoreTests: XCTestCase {
    func testOutputStateAfterMutationsSentThroughStore() {
        // Given a store of Count
        let store = Store(state: Count())
        let spy = PublisherSpy(store)

        // When mutations of Count are sent
        store.send(Count.Add(10))
        store.send(Count.Add(-20))

        // Then the Count state should reflect those mutations
        let outputs = spy.outputs.map(\.count)

        XCTAssertEqual(outputs, [0, 10, -10])
    }

    func testOutputStateAfterMutationsSentThroughRelatedStores() {
        // Given a store Counts and multiple stores of its substates
        let countsStore = Store(state: Counts())
        let countsSpy = PublisherSpy(countsStore)

        let countsArrayStore = countsStore.scope(state: \.counts)
        let countsArraySpy = PublisherSpy(countsArrayStore)
        // Need to push Count states into first and second indices for following stores
        countsArrayStore.send([Count].Push())
        countsArrayStore.send([Count].Push())

        let firstCountStore = countsStore.scope(state: \.counts[0])
        let firstCountSpy = PublisherSpy(firstCountStore.removeDuplicates())

        let secondCountStore = countsStore.scope(state: \.counts[1])
        let secondCountSpy = PublisherSpy(secondCountStore.removeDuplicates())

        // When mutations are sent to any of the stores
        firstCountStore.send(Count.Add(10))
        countsArrayStore.send([Count].Add(-20, to: \.[0]))
        secondCountStore.send(Count.Add(-20))
        countsArrayStore.send([Count].Add(40, to: \.[1]))

        // Then the state of each store should be consistent
        let countsOutputs = countsSpy.outputs.map { output in
            output.counts.map(\.count)
        }

        let countsArrayOutputs = countsArraySpy.outputs.map { output in
            output.map(\.count)
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
        XCTAssertEqual(countsArrayOutputs, countsOutputs)
        XCTAssertEqual(firstCountOutputs, [0, 10, -10])
        XCTAssertEqual(secondCountOutputs, [0, -20, 20])
    }
}
