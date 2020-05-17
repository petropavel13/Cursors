import Cursors
import XCTest

extension CloneableType where Self: CursorType, Element: Equatable {
    func testForwardResultsAreEqualToClone() -> XCTestExpectation {
        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(String(describing: testForwardResultsAreEqualToClone)) expectation")

        let copy = clone()

        drainForward() { firstRunResult in
            copy.drainForward { secondRunResult in
                XCTAssertTrue(firstRunResult.equals(to: secondRunResult),
                              "Got different results from original and cloned cursor!")

                expectation.fulfill()
            }
        }

        return expectation
    }
}
