import XCTest
import Cursors

final class StubCursorTests: BaseCursorTestCase<StubCursor<Int>> {

    override func createDefaultTestCursor() -> StubCursor<Int> {
        return StubCursor(pages: defaultTestPages)
    }

    static var allTests = [
        ("testOneDirectionDrain", testOneDirectionDrain),
        ("testResettableType", testResettableType),
    ]
}
