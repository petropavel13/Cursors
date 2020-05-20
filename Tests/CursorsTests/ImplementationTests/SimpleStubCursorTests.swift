import XCTest
import Cursors

final class SimpleStubCursorTests: BaseCursorTestCase<SimpleStubCursor<Int>> {

    override var defaultTestPages: [[Int]] {
        return [[1,2,3],[4,5]]
    }

    override func createDefaultTestCursor(pages: [[Int]]) -> SimpleStubCursor<Int> {
        return SimpleStubCursor(pages: pages)
    }

    // Stupid code to force Xcode execute parent tests

    func testResettableTrait() {
        super.testResettableTrait()
    }

    func testClonableTrait() {
        super.testClonableTrait()
    }

    static var allTests = [
        ("testOneDirectionDrain", testOneDirectionDrainForward),
        ("testResettableTrait", testResettableTrait),
        ("testClonableTrait", testClonableTrait),
    ]
}
