import Cursors
import XCTest

extension ResettableType where Self: CursorType, Element: Equatable {
    func forwardResultsAreEqualAfterReset() -> XCTestExpectation {
        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(#function) expectation")

        drainForward() { firstRunResult in
            self.reset().drainForward { secondRunResult in
                XCTAssertEqual(firstRunResult, secondRunResult,
                               "Got different results from first and second run of same cursor!")

                expectation.fulfill()
            }
        }

        return expectation
    }
}
