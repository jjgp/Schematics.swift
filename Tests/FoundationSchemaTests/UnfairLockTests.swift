import FoundationSchema
import XCTest

class UnfairLockTests: XCTestCase {
    func testConcurrentWrites() {
        let counter = Counter()
        let expectation = expectation(description: "Concurrent writes are synchronized")
        expectation.expectedFulfillmentCount = 2
        let iterations = 1000

        DispatchQueue.global(qos: .default).async {
            for _ in 0 ..< iterations {
                counter.increment()
            }
            expectation.fulfill()
        }

        DispatchQueue.global(qos: .default).async {
            for _ in 0 ..< iterations {
                counter.increment()
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(counter.count, 2 * iterations)
    }
}

private extension UnfairLockTests {
    class Counter {
        private(set) var count: Int = 0
        private let lock: UnfairLock

        init() {
            lock = .init()
        }

        func increment() {
            lock {
                count += 1
            }
        }
    }
}
