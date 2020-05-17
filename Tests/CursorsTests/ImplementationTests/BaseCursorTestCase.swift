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

        wait(for: cursor.testPagesEqual(to: defaultTestPages), timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: ResettableType {
    func testResettableType() {
        let nonEmptyCursorExpectation = createDefaultTestCursor(pages: defaultTestPages)
            .testForwardResultsAreEqualAfterReset()

        let emptyCursorExpectation = createDefaultTestCursor(pages: [])
            .testForwardResultsAreEqualAfterReset()

        wait(for: [nonEmptyCursorExpectation, emptyCursorExpectation], timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: CloneableType {
    func testClonableType() {
        let nonEmptyCursorExpectation = createDefaultTestCursor(pages: defaultTestPages)
            .testForwardResultsAreEqualToClone()

        let emptyCursorExpectation = createDefaultTestCursor(pages: [])
            .testForwardResultsAreEqualToClone()

        wait(for: [nonEmptyCursorExpectation, emptyCursorExpectation], timeout: 10)
    }
}
