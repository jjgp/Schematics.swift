import Combine
import ReactiveSchema
import UnidirectionalSchema
import XCTest

final class StoreTests: XCTestCase {
    func testActionsOnCountStore() {
        let store = Store(state: Count(), mutation: mutation(count:action:))
        let spy = PublisherSpy(store)

        store.send(Count.Add(10))
        store.send(Count.Add(-20))

        let outputs = spy.outputs.map(\.count)
        XCTAssertEqual(outputs, [0, 10, -10])
    }

    func testMultipleStoresInScope() {
        let countsStore = Store(state: Counts(), mutation: mutation(counts:action:))
        let countsSpy = PublisherSpy(countsStore)
        let firstCountStore = countsStore.scope(state: \.first, mutation: mutation(count:action:))
        let firstCountSpy = PublisherSpy(firstCountStore.removeDuplicates())
        let secondCountStore = countsStore.scope(state: \.second, mutation: mutation(count:action:))
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

    func testActionsSentFromSubscriptionAreBuffered() {
        let countStore = Store(dispatcher: BarrierDispatcher(), state: Count(), mutation: mutation(count:action:))
        let countSpy = PublisherSpy(countStore)

        let cancellable = countStore.subscribe { [weak countStore] state in
            if state.count == 10 {
                countStore?.send(Count.Add(-10))
            }
        }

        countStore.send(Count.Add(10))
        countStore.send(Count.Add(10))

        let countValues = countSpy.outputs.map(\.count)
        XCTAssertEqual(countValues, [0, 10, 0, 10, 0])
        cancellable.cancel()
    }

    // swiftlint:disable function_body_length
    func testActionsSentFromSubscriptionsOfScopeStoresAreBuffered() {
        let dispatcherSpy = DispatcherSpy()
        let countsStore = Store(
            dispatcher: dispatcherSpy,
            state: Counts(),
            mutation: mutation(counts:action:)
        )
        let firstCountStore = countsStore.scope(state: \.first, mutation: mutation(count:action:))
        let secondCountStore = countsStore.scope(state: \.second, mutation: mutation(count:action:))

        var cancellables = Set<AnyCancellable>()

        countsStore.subscribe { [weak countsStore] state in
            if state.first.count == 10 {
                countsStore?.send(Counts.Add(-10, to: \.first))
            }

            if state.second.count == 10 {
                countsStore?.send(Counts.Add(-10, to: \.second))
            }
        }
        .store(in: &cancellables)

        firstCountStore.subscribe { [weak firstCountStore] state in
            if state.count == 10 {
                firstCountStore?.send(Count.Add(-10))
            }
        }
        .store(in: &cancellables)

        secondCountStore.subscribe { [weak secondCountStore] state in
            if state.count == 10 {
                secondCountStore?.send(Count.Add(-10))
            }
        }
        .store(in: &cancellables)

        firstCountStore.send(Count.Add(10))
        dispatcherSpy.dispatch()
        XCTAssertEqual(dispatcherSpy.dispatched(at: 0), Count.Add(10))
        XCTAssertEqual(dispatcherSpy.buffer.count, 2)

        dispatcherSpy.dispatch()
        dispatcherSpy.dispatch()
        XCTAssertEqual(dispatcherSpy.dispatched(between: 1 ... 2), Count.Add(-10))

        let countsFirstAdd: Counts.Add? = dispatcherSpy.dispatched(between: 1 ... 2)
        XCTAssertEqual(countsFirstAdd?.keyPath, \.first)
        XCTAssertEqual(countsFirstAdd?.value, -10)

        secondCountStore.send(Count.Add(10))
        dispatcherSpy.dispatch()
        XCTAssertEqual(dispatcherSpy.dispatched(at: 3), Count.Add(10))
        XCTAssertEqual(dispatcherSpy.buffer.count, 2)

        dispatcherSpy.dispatch()
        dispatcherSpy.dispatch()
        XCTAssertEqual(dispatcherSpy.dispatched(between: 4 ... 5), Count.Add(-10))

        let countsSecondAdd: Counts.Add? = dispatcherSpy.dispatched(between: 4 ... 5)
        XCTAssertEqual(countsSecondAdd?.keyPath, \.second)
        XCTAssertEqual(countsSecondAdd?.value, -10)
    }
    // swiftlint:enable function_body_length
}
