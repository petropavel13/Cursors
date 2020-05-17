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

    static var allTests = [
        ("testOneDirectionDrain", testOneDirectionDrain),
        ("testResettableType", testResettableType),
        ("testClonableType", testClonableType),
    ]
}
