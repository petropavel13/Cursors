import Cursors
import XCTest

extension ResettableType where Self: CursorType, Element: Equatable {
    func testForwardResultsAreEqualAfterReset() -> XCTestExpectation {
        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(String(describing: testForwardResultsAreEqualAfterReset)) expectation")

        drainForward() { (firstRunResults, firstRunCursorError) in
            self.reset().drainForward { (secondRunResults, secondRunCursorError) in
                switch (firstRunCursorError, secondRunCursorError) {
                case (nil, nil):
                    XCTAssertEqual(firstRunResults, secondRunResults)
                case let (firstRunCursorError?, secondRunCursorError?):
                    XCTAssertEqual(firstRunResults, secondRunResults)
                    XCTAssertEqual(firstRunCursorError.isExhausted, secondRunCursorError.isExhausted)
                default:
                    XCTFail("Got different results from first and second run of same cursor!")
                }

                expectation.fulfill()
            }
        }

        return expectation
    }
}

private extension CursorType {
    func drainForward(accumulatingResult: [Element] = [], completion: @escaping ([Element], Failure?) -> Void) {
        loadNextPage {
            switch $0 {
            case let .success((elements, exhausted)):
                let overallResults = accumulatingResult + elements

                if exhausted {
                    completion(overallResults, nil)
                } else {
                    self.drainForward(accumulatingResult: overallResults,
                                      completion: completion)
                }
            case let .failure(cursorError):
                completion(accumulatingResult, cursorError)
            }
        }
    }
}
