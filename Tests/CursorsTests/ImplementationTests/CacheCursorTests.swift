@testable import Cursors
import XCTest

final class CacheCursorTests: BaseCursorTestCase<StubCursor<Int>.InMemoryCacheCursorType> {

    override var defaultTestPages: [[Int]] {
        return [[1,2,3],[4,5]]
    }

    override func createDefaultTestCursor(pages: [[Int]]) -> StubCursor<Int>.InMemoryCacheCursorType {
        return StubCursor(pages: pages).cached()
    }

    // Stupid code to force Xcode execute parent tests

    func testResettableTrait() {
        super.baseTestResettableTrait()
    }

    func testClonableTrait() {
        super.baseTestClonableTrait()
    }

    func testOneDirectionDrainBackward() {
        super.baseTestOneDirectionDrainBackward()
    }

    func testOneDirectionDrainRequestCount() {
        let stubCursor = StubCursor(pages: defaultTestPages)

        let initialPosition = StubCursor.Position(pages: defaultTestPages, pageIndex: 0, elementIndex: 0)

        let countableCursor = stubCursor.countRequests()
        let cacheCursor1 = countableCursor.cached()
        let cacheCursor2 = cacheCursor1.copy()
        let cacheCursor3 = cacheCursor1.copy()

        let expectation = XCTestExpectation(description: "\(#function) expectation")

        let testPagesCount = defaultTestPages.count

        cacheCursor1.drainForward { _ in
            let loadNextPageCallCount = countableCursor.eventHandler.onLoadForwardCount

            XCTAssertEqual(loadNextPageCallCount, testPagesCount)

            stubCursor.seek(to: initialPosition)

            cacheCursor2.drainForward { _ in
                let loadNextPageCallCountAfterSecondDrain = countableCursor.eventHandler.onLoadForwardCount
                let loadNextPageCallCountWithExhaustedNonCached = loadNextPageCallCount + 1

                XCTAssertEqual(loadNextPageCallCountAfterSecondDrain, loadNextPageCallCountWithExhaustedNonCached)

                cacheCursor3.clear()

                stubCursor.seek(to: initialPosition)

                cacheCursor3.drainForward { _ in
                    let loadNextPageCallCountAfterNonCached = countableCursor.eventHandler.onLoadForwardCount
                    XCTAssertEqual(loadNextPageCallCountAfterNonCached, loadNextPageCallCountWithExhaustedNonCached + testPagesCount)

                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    static var allTests = [
        ("testOneDirectionDrainForward", testOneDirectionDrainForward),
        ("testOneDirectionDrainBackward", testOneDirectionDrainBackward),
        ("testResettableTrait", testResettableTrait),
        ("testClonableTrait", testClonableTrait),
        ("testOneDirectionDrainRequestCount", testOneDirectionDrainRequestCount)
    ]
}
