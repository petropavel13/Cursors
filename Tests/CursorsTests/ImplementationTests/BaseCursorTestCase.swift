import XCTest
import Cursors

class BaseCursorTestCase<Cursor: CursorType>: XCTestCase where Cursor.Element: Equatable {

    var defaultTestPages: [[Cursor.Element]] {
        fatalError("Override defaultTestPages in subclass!")
    }

    func createDefaultTestCursor(pages: [[Cursor.Element]]) -> Cursor {
        fatalError("Override \(String(describing: createDefaultTestCursor)) in subclass!")
    }

    func testOneDirectionDrain() {
        let cursor = createDefaultTestCursor(pages: defaultTestPages)

        let expectation = cursor.forwardResultEqual(to: DrainResult(pages: defaultTestPages, error: nil))

        wait(for: [expectation], timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: ResettableType {
    func testResettableType() {
        let nonEmptyCursorExpectation = createDefaultTestCursor(pages: defaultTestPages)
            .forwardResultsAreEqualAfterReset()

        let emptyCursorExpectation = createDefaultTestCursor(pages: [])
            .forwardResultsAreEqualAfterReset()

        wait(for: [nonEmptyCursorExpectation, emptyCursorExpectation], timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: CloneableType {
    func testClonableType() {
        let nonEmptyCursorExpectation = createDefaultTestCursor(pages: defaultTestPages)
            .forwardResultsAreEqualToClone()

        let emptyCursorExpectation = createDefaultTestCursor(pages: [])
            .forwardResultsAreEqualToClone()

        wait(for: [nonEmptyCursorExpectation, emptyCursorExpectation], timeout: 10)
    }
}
