import Cursors
import XCTest

extension CursorType where Element: Equatable {
    func testPagesEqual(to pages: [[Element]]) -> [XCTestExpectation] {
        let cursorType = type(of: self)

        let realPageExpectations: [XCTestExpectation] = pages.enumerated().map { (pageIndex, pageContent) in
            let expectation = XCTestExpectation(description: "\(cursorType) \(pageIndex) page expectation")

            let isLastPage = pageIndex == pages.index(before: pages.endIndex)

            loadNextPage {
                switch $0 {
                case let .success((elements, exhausted)):
                    XCTAssertEqual(elements, pageContent)
                    XCTAssertEqual(exhausted, isLastPage)
                case let .failure(error):
                    XCTFail("\(type(of: error)) -> \(error)")
                }
                expectation.fulfill()
            }

            return expectation
        }

        let nonExistedPageExpectation = XCTestExpectation(description: "\(cursorType) nonexistent page expectation")

        loadNextPage {
            switch $0 {
            case let .success((elements, exhausted)):
                XCTFail("Unexpected results: \(elements), exhausted: \(exhausted)")
            case let .failure(error):
                XCTAssertTrue(error.isExhausted)
            }
            nonExistedPageExpectation.fulfill()
        }

        return realPageExpectations + [nonExistedPageExpectation]
    }
}
