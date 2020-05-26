import XCTest
@testable import Cursors

final class FixedPageCursorTests: BaseCursorTestCase<FixedPageCursor<StubCursor<Int>>> {

    override var defaultTestPages: Pages {
        return [[1,2,3,4],[5],[6]]
    }

    override var expectedForwardResults: Pages {
        return [[1,2],[3,4],[5,6]]
    }

    override func createDefaultTestCursor(pages: [[Int]]) -> FixedPageCursor<StubCursor<Int>> {
        return StubCursor(pages: pages).paged(by: 2)
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

    func testPositionableTraitForwardDrain() {
        super.baseTestPositionableTraitForwardDrain()
    }

    func testPositionableTraitBackwardDrain() {
        super.baseTestPositionableTraitBackwardDrain()
    }

    func testBufferForwardDrain() {
        let countableCursor = StubCursor(pages: defaultTestPages).countRequests()
        let pagedCursor = countableCursor.paged(by: 2)

        let testPagesCount = defaultTestPages.count

        let expectation = XCTestExpectation(description: "\(#function) expectation")

        pagedCursor.drainForward { _ in
            XCTAssertEqual(countableCursor.eventHandler.onLoadForwardCount, testPagesCount)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    static var allTests = [
        ("testOneDirectionDrainForward", testOneDirectionDrainForward),
        ("testOneDirectionDrainBackward", testOneDirectionDrainBackward),
        ("testResettableTrait", testResettableTrait),
        ("testClonableTrait", testClonableTrait),
        ("testPositionableTraitForwardDrain", testPositionableTraitForwardDrain),
        ("testPositionableTraitBackwardDrain", testPositionableTraitBackwardDrain),
        ("testBufferForwardDrain", testBufferForwardDrain),
    ]
}
