import Combine
import UnidirectionalSchema
import XCTest

final class ReactionMiddlewareTests: XCTestCase {
    func testOutputStateAfterMutationsSentThroughStoreWithAReaction() {
        // Given a store of Count
        let store = Store(middleware: ReactionMiddleware(reaction: Count.Decrement()), state: Count())
        let spy = PublisherSpy(store)

        // When mutations of Count are sent
        store.send(Count.Add(10))

        // Then the Count state should reflect those mutations
        let outputs = spy.outputs.map(\.count)

        XCTAssertEqual(outputs, [0, 10, 0])
    }

    func testOutputStateAfterMutationsSentThroughStoreWithMultipleReactions() {
        // Given a store of Count
        let store = Store(
            middleware: ReactionMiddleware(reactions: Count.Decrement(), Count.Decrement()),
            state: Count()
        )
        let spy = PublisherSpy(store)

        // When mutations of Count are sent
        store.send(Count.Add(10))

        // Then the Count state should reflect those mutations
        let outputs = spy.outputs.map(\.count)

        XCTAssertEqual(outputs, [0, 10, 0, -10])
    }

    func testOutputStateAfterMutationsSentThroughRelatedStoreWithMultipleReactions() {
        // Given a store Counts and multiple stores of its substates
        let countsStore = Store(
            middleware: ReactionMiddleware(reactions: Counts.DecrementCounts()),
            state: Counts()
        )
        let countsSpy = PublisherSpy(countsStore)

        let countsArrayStore = countsStore.scope(state: \.counts)
        let countsArraySpy = PublisherSpy(countsArrayStore)
        // Need to push Count states into first and second indices for following stores
        countsArrayStore.send(Counts.Push())
        countsArrayStore.send(Counts.Push())

        let firstCountStore = countsArrayStore.scope(state: \.[0])
        let firstCountSpy = PublisherSpy(firstCountStore.removeDuplicates())

        let secondCountStore = countsArrayStore.scope(state: \.[1])
        let secondCountSpy = PublisherSpy(secondCountStore.removeDuplicates())

        // When mutations are sent to any of the stores
        firstCountStore.send(Count.Add(10))
        countsArrayStore.send(Counts.Add(-20, to: \.[0]))
        secondCountStore.send(Count.Add(-20))
        countsArrayStore.send(Counts.Add(40, to: \.[1]))

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
            [0, 0],
            [-20, 0],
            [-20, -20],
            [-20, 0],
            [-20, 40]
        ])
        XCTAssertEqual(countsArrayOutputs, countsOutputs)
        XCTAssertEqual(firstCountOutputs, [0, 10, 0, -20])
        XCTAssertEqual(secondCountOutputs, [0, -20, 0, 40])
    }
}
