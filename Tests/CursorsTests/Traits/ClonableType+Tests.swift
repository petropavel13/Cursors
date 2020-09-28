import Cursors
import XCTest

extension CloneableType where Self: CursorType, Page.Item: Equatable {
    func forwardResultsAreEqualToClone() -> XCTestExpectation {
        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(#function) expectation")

        let copy = clone()

        drainForward() { firstRunResult in
            copy.drainForward { secondRunResult in
                XCTAssertEqual(firstRunResult, secondRunResult,
                               "Got different results from original and cloned cursor!")

                expectation.fulfill()
            }
        }

        return expectation
    }
}
