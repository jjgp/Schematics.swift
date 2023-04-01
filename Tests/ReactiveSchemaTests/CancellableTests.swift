import ReactiveSchema
import XCTest

class CancellableTests: XCTestCase {
    func testCancelInvokesOnCancelBlock() {
        // Given
        var isCancelled = false
        let cancellable = Cancellable {
            isCancelled = true
        }
        XCTAssertFalse(isCancelled)

        // When
        cancellable.cancel()

        // Then
        XCTAssertTrue(isCancelled)
    }

    func testCancelInvokesOnCancelBlockOnlyOnce() {
        // Given
        var cancelledCount = 0
        let cancellable = Cancellable {
            cancelledCount += 1
        }

        // When
        cancellable.cancel()
        cancellable.cancel()

        // Then
        XCTAssertEqual(cancelledCount, 1)
    }

    func testDeinitInvokesOnCancel() {
        // Given
        var isCancelled = false

        // When
        _ = Cancellable {
            isCancelled = true
        }

        // Then
        XCTAssertTrue(isCancelled)
    }
}
