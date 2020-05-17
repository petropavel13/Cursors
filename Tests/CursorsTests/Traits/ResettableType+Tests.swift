import Cursors
import XCTest

extension ResettableType where Self: CursorType, Element: Equatable {
    func testForwardResultsAreEqualAfterReset() -> XCTestExpectation {
        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(String(describing: testForwardResultsAreEqualAfterReset)) expectation")

        drainForward() { firstRunResult in
            self.reset().drainForward { secondRunResult in
                XCTAssertTrue(firstRunResult.equals(to: secondRunResult),
                              "Got different results from first and second run of same cursor!")

                expectation.fulfill()
            }
        }

        return expectation
    }
}
