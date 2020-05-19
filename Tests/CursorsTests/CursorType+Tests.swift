import Cursors
import XCTest

extension CursorType where Element: Equatable {
    func drainResultEqual(to result: DrainResult<Self>,
                          drainClosure: @escaping (@escaping DrainCompletion) -> Void,
                          nextPageClosure: @escaping (@escaping ResultCompletion) -> Void) -> XCTestExpectation {

        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) \(String(describing: forwardResultEqual)) expectation")

        drainClosure {
            XCTAssertEqual($0, result,
                           "Got different results from first and second run of same cursor!")

            nextPageClosure {
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

    func forwardResultEqual(to result: DrainResult<Self>) -> XCTestExpectation {
        return drainResultEqual(to: result,
                                drainClosure: { self.drainForward(completion: $0) },
                                nextPageClosure: { self.loadNextPage(completion: $0) })
    }
}
