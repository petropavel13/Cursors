import XCTest
import Cursors

final class StubCursorTests: BaseCursorTestCase<StubCursor<Int>> {

    override var defaultTestPages: [[Int]] {
        return [[1,2,3],[4,5]]
    }

    override func createDefaultTestCursor(pages: [[Int]]) -> StubCursor<Int> {
        return StubCursor(pages: pages)
    }

    // Stupid code to force Xcode execute parent tests

    func testResettableType() {
        super.testResettableType()
    }

    func testClonableType() {
        super.testClonableType()
    }

    func testOneDirectionDrainBackward() {
        super.testOneDirectionDrainBackward()
    }

    func testPositionableTrait() {
        let positionableCursor = createDefaultTestCursor(pages: defaultTestPages)

        let initialPosition = positionableCursor.currentPosition

        // Drain forward from middle position of first page

        let firstPageMiddlePosition = initialPosition.offset(elements: 2)

        let expectedForwardResult = DrainResult<StubCursor<Int>>(pages: [[3],[4,5]], error: nil)

        let drainForwardCursor = positionableCursor.clone()

        let forwardExpectation = drainForwardCursor.expectResults(after: firstPageMiddlePosition,
                                                                  equalsTo: expectedForwardResult)

        // Drain backward from middle position of first page

        let expectedBackwardResult = DrainResult<StubCursor<Int>>(pages: [[1,2]], error: nil)

        let drainBackwardCursor = positionableCursor.clone()

        let backwardExpectation = drainBackwardCursor.expectResults(before: firstPageMiddlePosition,
                                                                    equalsTo: expectedBackwardResult)

        // Drain forward from boundary position between pages

        let drainBoundaryPosition = initialPosition.offset(elements: 3)

        let expectedForwardBoundaryResult = DrainResult<StubCursor<Int>>(pages: [[4,5]], error: nil)

        let boundaryDrainForwardCursor = positionableCursor.clone()

        let forwardBoundaryExpectation = boundaryDrainForwardCursor.expectResults(after: drainBoundaryPosition,
                                                                                  equalsTo: expectedForwardBoundaryResult)

        // Drain backward from boundary position between pages

        let expectedBackwardBoundaryResult = DrainResult<StubCursor<Int>>(pages: [[1,2,3]], error: nil)

        let boundaryDrainBackwardCursor = positionableCursor.clone()

        let backwardBoundaryExpectation = boundaryDrainBackwardCursor.expectResults(before: drainBoundaryPosition,
                                                                                    equalsTo: expectedBackwardBoundaryResult)

        wait(for: [forwardExpectation,
                   backwardExpectation,
                   forwardBoundaryExpectation,
                   backwardBoundaryExpectation], timeout: 10.0)
    }

    static var allTests = [
        ("testOneDirectionDrain", testOneDirectionDrainForward),
        ("testOneDirectionDrainBackward", testOneDirectionDrainBackward),
        ("testResettableType", testResettableType),
        ("testClonableType", testClonableType),
        ("testPositionableTrait", testPositionableTrait),
    ]
}
