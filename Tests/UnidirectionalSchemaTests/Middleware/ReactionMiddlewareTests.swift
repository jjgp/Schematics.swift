import Combine
import UnidirectionalSchema
import XCTest

final class ReactionMiddlewareTests: XCTestCase {
    func testReactionMiddlewareInCountStore() {
        let store = Store(middleware: ReactionMiddleware(reaction: Count.Decrement()), state: Count())
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

    func testReactionMiddlewareWithMultipleStoresInScope() {
        let countsStore = Store(
            middleware: ReactionMiddleware(reactions: Counts.DecrementCounts()),
            state: Counts()
        )
        let countsSpy = PublisherSpy(countsStore)

        let countsArrayStore = countsStore.scope(state: \.counts)
        countsArrayStore.send(Counts.Push())
        countsArrayStore.send(Counts.Push())

        let firstCountStore = countsArrayStore.scope(state: \.[0])
        let firstCountSpy = PublisherSpy(firstCountStore.removeDuplicates())

        let secondCountStore = countsArrayStore.scope(state: \.[1])
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
            [0, 0],
            [-20, 0],
            [-20, -20],
            [-20, 0],
            [-20, 40]
        ])
        XCTAssertEqual(firstCountOutputs, [0, 10, 0, -20])
        XCTAssertEqual(secondCountOutputs, [0, -20, 0, 40])
    }
}
