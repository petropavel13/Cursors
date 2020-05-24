import XCTest
import Cursors

class BaseCursorTestCase<Cursor: CursorType>: XCTestCase where Cursor.Element: Equatable {

    var defaultTestPages: [[Cursor.Element]] {
        fatalError("Override defaultTestPages in subclass!")
    }

    func createDefaultTestCursor(pages: [[Cursor.Element]]) -> Cursor {
        fatalError("Override \(String(describing: createDefaultTestCursor)) in subclass!")
    }

    func testOneDirectionDrainForward() {
        let cursor = createDefaultTestCursor(pages: defaultTestPages)

        let expectation = cursor.forwardResultEqual(to: DrainResult(pages: defaultTestPages, error: nil))

        wait(for: [expectation], timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: BidirectionalCursorType {
    func baseTestOneDirectionDrainBackward() {
        let cursor = createDefaultTestCursor(pages: defaultTestPages)

        let expectation = XCTestExpectation(description: "\(type(of: self)) \(#function) expectation")

        let expectedForwardResult = DrainResult<Cursor>(pages: defaultTestPages, error: nil)
        let expectedBackwardResult = DrainResult<Cursor>(pages: defaultTestPages.reversed(), error: nil)

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
