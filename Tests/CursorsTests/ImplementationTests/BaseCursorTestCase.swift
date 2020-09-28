import XCTest
import Cursors

class BaseCursorTestCase<Cursor: CursorType>: XCTestCase where Cursor.Page.Item: Equatable {

    typealias DrainResultType = DrainResult<Cursor>
    typealias Pages = [[Cursor.Page.Item]]

    var defaultTestPages: Pages {
        fatalError("Override \(#function) in subclass!")
    }

    var expectedForwardResults: Pages {
        return defaultTestPages
    }

    func createDefaultTestCursor(pages: Pages) -> Cursor {
        fatalError("Override \(#function) in subclass!")
    }

    func testOneDirectionDrainForward() {
        let cursor = createDefaultTestCursor(pages: defaultTestPages)

        let expectation = cursor.forwardResultEqual(to: DrainResult(pages: expectedForwardResults, error: nil))

        wait(for: [expectation], timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: BidirectionalCursorType {
    func baseTestOneDirectionDrainBackward() {
        let cursor = createDefaultTestCursor(pages: defaultTestPages)

        let expectation = XCTestExpectation(description: "\(type(of: self)) \(#function) expectation")

        let expectedForwardResult = DrainResultType(pages: expectedForwardResults, error: nil)
        let expectedBackwardResult = DrainResultType(pages: expectedForwardResults.reversed(), error: nil)

        cursor.drainForward {
            XCTAssertEqual($0, expectedForwardResult, "Got unexpected result from forward drain!")

            cursor.drainBackward {
                XCTAssertEqual($0, expectedBackwardResult, "Got unexpected result from backward drain!")

                cursor.drainBackward {
                    XCTAssertEqual($0, DrainResult(pages: [], error: .exhaustedError))

                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: ResettableType {
    func baseTestResettableTrait() {
        let nonEmptyCursorExpectation = createDefaultTestCursor(pages: defaultTestPages)
            .forwardResultsAreEqualAfterReset()

        let emptyCursorExpectation = createDefaultTestCursor(pages: [])
            .forwardResultsAreEqualAfterReset()

        wait(for: [nonEmptyCursorExpectation, emptyCursorExpectation], timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: CloneableType {
    func baseTestClonableTrait() {
        let nonEmptyCursorExpectation = createDefaultTestCursor(pages: defaultTestPages)
            .forwardResultsAreEqualToClone()

        let emptyCursorExpectation = createDefaultTestCursor(pages: [])
            .forwardResultsAreEqualToClone()

        wait(for: [nonEmptyCursorExpectation, emptyCursorExpectation], timeout: 10)
    }
}

extension Array where Element: Equatable {
    func drop(until element: Element, includingElement: Bool) -> Self {
        guard contains(element) else {
            return self
        }

        return Self(drop { $0 != element || ($0 == element && includingElement) })
    }
}

extension BaseCursorTestCase where Cursor: ElementStrideableType,
    Cursor.Position.ElementIndex.Stride == Pages.Index.Stride,
    Cursor.Page.Item: Equatable {

    func baseTestPositionableTraitForwardDrain() {
        let positionableCursor = createDefaultTestCursor(pages: defaultTestPages)

        let firstPage = defaultTestPages[0]
        let firstPageMiddleIndex = firstPage.count / 2
        let firstPageMiddlePosition = positionableCursor.position(advancedBy: firstPageMiddleIndex)!

        let firstPageTrailingElements = Array(firstPage.suffix(from: firstPageMiddleIndex))

        let firstPageTrailingElementsFirstItem = firstPageTrailingElements[0]

        let trailingPagesAfterFirstPageLeadingItems = expectedForwardResults
            .drop { !$0.contains(firstPageTrailingElementsFirstItem) }
            .map { $0.drop(until: firstPageTrailingElementsFirstItem, includingElement: false) }

        // Drain forward from middle position of first page

        let expectedForwardResult = DrainResultType(pages: trailingPagesAfterFirstPageLeadingItems, error: nil)

        let drainForwardCursor = createDefaultTestCursor(pages: defaultTestPages)

        let forwardExpectation = drainForwardCursor.expectResults(after: firstPageMiddlePosition,
                                                                  equalsTo: expectedForwardResult)

        // Drain forward from boundary position between pages

        let drainBoundaryPosition = positionableCursor.position(advancedBy: firstPage.count)!

        let firstPageLastItem = firstPage.last!

        var trailingPagesAfterFirstPage = expectedForwardResults
            .drop { !$0.contains(firstPageLastItem) }
            .map { $0.drop(until: firstPageLastItem, includingElement: true) }
        trailingPagesAfterFirstPage.removeAll { $0.isEmpty }

        let expectedForwardBoundaryResult = DrainResultType(pages: trailingPagesAfterFirstPage, error: nil)

        let boundaryDrainForwardCursor = createDefaultTestCursor(pages: defaultTestPages)

        let forwardBoundaryExpectation = boundaryDrainForwardCursor.expectResults(after: drainBoundaryPosition,
                                                                                  equalsTo: expectedForwardBoundaryResult)

        wait(for: [forwardExpectation, forwardBoundaryExpectation], timeout: 10.0)
    }
}

extension BaseCursorTestCase where Cursor: ElementStrideableType & BidirectionalCursorType,
    Cursor.Position.ElementIndex.Stride == Pages.Index.Stride,
    Cursor.Page.Item: Equatable {

    func baseTestPositionableTraitBackwardDrain() {
        let drainBackwardCursor = createDefaultTestCursor(pages: defaultTestPages)

        let firstPage = defaultTestPages[0]
        let firstPageMiddleIndex = firstPage.count / 2
        let firstPageMiddlePosition = drainBackwardCursor.position(advancedBy: firstPageMiddleIndex)!

        let firstPageLeadingElements = Array(firstPage.prefix(upTo: firstPageMiddleIndex))

        // Drain backward from middle position of first page

        let expectedBackwardResult = DrainResultType(pages: [firstPageLeadingElements], error: nil)

        let backwardExpectation = drainBackwardCursor.expectResults(before: firstPageMiddlePosition,
                                                                    equalsTo: expectedBackwardResult)

        // Drain backward from boundary position between pages

        let expectedPages = expectedForwardResults.reversed()
            .drop { !$0.contains(where: firstPage.contains) }
            .map { $0.filter(firstPage.contains) }

        let expectedBackwardBoundaryResult = DrainResultType(pages: expectedPages, error: nil)

        let boundaryDrainBackwardCursor = createDefaultTestCursor(pages: defaultTestPages)

        let drainBoundaryPosition = boundaryDrainBackwardCursor.position(advancedBy: firstPage.count)!

        let backwardBoundaryExpectation = boundaryDrainBackwardCursor.expectResults(before: drainBoundaryPosition,
                                                                                    equalsTo: expectedBackwardBoundaryResult)

        wait(for: [backwardExpectation, backwardBoundaryExpectation], timeout: 10.0)
    }
}
