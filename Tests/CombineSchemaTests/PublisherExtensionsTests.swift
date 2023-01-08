import CombineSchema
import XCTest

class PublisherExtensionsTests: XCTestCase {
    func testAwait() {
        let subject = PassthroughSubject<Int, Never>()
        subject
            .await(operation: asyncReturn)
    }
}
