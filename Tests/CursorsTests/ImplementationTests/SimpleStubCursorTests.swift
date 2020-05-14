import XCTest
import Cursors

final class SimpleStubCursorTests: BaseCursorTestCase<SimpleStubCursor<Int>> {

    override func createDefaultTestCursor() -> SimpleStubCursor<Int> {
        return SimpleStubCursor(pages: defaultTestPages)
    }

    static var allTests = [
        ("testOneDirectionDrain", testOneDirectionDrain),
        ("testResettableType", testResettableType),
    ]
}
