import ReactiveSchema
import XCTest

class CancellableTests: XCTestCase {
    func testCancelInvokesOnCancelBlock() {
        var isCancelled = false
        let cancellable = Cancellable {
            isCancelled = true
        }

        XCTAssertFalse(isCancelled)
        cancellable.cancel()
        XCTAssertTrue(isCancelled)
    }

    func testCancelInvokesOnCancelBlockOnlyOnce() {
        var cancelledCount = 0
        let cancellable = Cancellable {
            cancelledCount += 1
        }

        cancellable.cancel()
        cancellable.cancel()
        XCTAssertEqual(cancelledCount, 1)
    }

    func testDeinitInvokesOnCancel() {
        var isCancelled = false
        _ = Cancellable {
            isCancelled = true
        }

        XCTAssertTrue(isCancelled)
    }
}
