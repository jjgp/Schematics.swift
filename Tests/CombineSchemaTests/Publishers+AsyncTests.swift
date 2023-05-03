import Combine
import CombineSchema
import XCTest

final class Publishers_AsyncTests: XCTestCase {
    func testMapAsync() {
        let expectation = expectation(description: "84")
        let subscription = Just(42)
            .flatMapAsync { input in
                await withCheckedContinuation { continuation in
                    continuation.resume(returning: input + 42)
                }
            }
            .sink {
                print($0)
            }

//        let subscription = Just(42)
//            .mapAsync { input in
//                await withCheckedContinuation { continuation in
//                    continuation.resume(returning: input + 42)
//                }
//            }
//            .sink {
//                print($0)
//            }
//
        wait(for: [expectation], timeout: 1.0)
    }
}
