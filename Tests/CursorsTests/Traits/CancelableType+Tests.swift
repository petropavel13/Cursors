import Cursors
import XCTest

extension CancelableCursorType where Element: Equatable {
    func cursorRequestCancelledBeforeCompletion() -> XCTestExpectation {
        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(#function) expectation")

        loadNextPage {
            switch $0 {
            case .success:
                XCTFail("Unexpected result. Expected \(Failure.cancelledError)")
            case let .failure(error):
                XCTAssertTrue(error.isCancelled, "Expected \(Failure.cancelledError). Got \(error)")
            }
        }

        cancel()

        return expectation
    }
}
