import Cursors
import XCTest

extension CursorType where Element: Equatable {
    func forwardResultEqual(to result: DrainResult<Self>) -> XCTestExpectation {
        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(String(describing: forwardResultEqual)) expectation")

        drainForward {
            XCTAssertEqual($0, result,
                           "Got different results from first and second run of same cursor!")

            self.loadNextPage {
                switch $0 {
                case let .success((elements, exhausted)):
                    XCTFail("Unexpected results: \(elements), exhausted: \(exhausted)")
                case let .failure(error):
                    XCTAssertTrue(error.isExhausted)
                }
                expectation.fulfill()
            }
        }

        return expectation
    }
}
