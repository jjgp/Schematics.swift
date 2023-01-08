import Combine
import CombineSchema
import XCTest

class PublisherExtensionsTests: XCTestCase {
    func testAwait() {
        let subject = PassthroughSubject<Int, Never>()
        _ = subject
            .await(operation: asyncReturn)
    }
}
