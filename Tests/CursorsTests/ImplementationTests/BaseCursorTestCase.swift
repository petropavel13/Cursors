import XCTest
import Cursors

class BaseCursorTestCase<Cursor: CursorType>: XCTestCase where Cursor.Element == Int {

    let defaultTestPages = [[1,2,3], [4,5]]

    func createDefaultTestCursor() -> Cursor {
        fatalError("Override \(String(describing: createDefaultTestCursor)) in subclass!")
    }

    func testOneDirectionDrain() {
        let cursor = createDefaultTestCursor()

        wait(for: cursor.testPagesEqual(to: defaultTestPages), timeout: 10)
    }
}

extension BaseCursorTestCase where Cursor: ResettableType {
    func testResettableType() {
        let expectation = createDefaultTestCursor().testForwardResultsAreEqualAfterReset()

        wait(for: [expectation], timeout: 10)
    }
}
