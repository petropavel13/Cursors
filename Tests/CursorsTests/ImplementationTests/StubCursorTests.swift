import XCTest
@testable import Cursors

final class StubCursorTests: BaseCursorTestCase<StubCursor<Int>> {

    override var defaultTestPages: [[Int]] {
        return [[1,2,3],[4,5]]
    }

    override func createDefaultTestCursor(pages: [[Int]]) -> StubCursor<Int> {
        return StubCursor(pages: pages)
    }

    // Stupid code to force Xcode execute parent tests

    func testResettableTrait() {
        super.baseTestResettableTrait()
    }

    func testClonableTrait() {
        super.baseTestClonableTrait()
    }

    func testOneDirectionDrainBackward() {
        super.baseTestOneDirectionDrainBackward()
    }

    func testPositionableTraitForwardDrain() {
        super.baseTestPositionableTraitForwardDrain()
    }

    func testPositionableTraitBackwardDrain() {
        super.baseTestPositionableTraitBackwardDrain()
    }

    static var allTests = [
        ("testOneDirectionDrainForward", testOneDirectionDrainForward),
        ("testOneDirectionDrainBackward", testOneDirectionDrainBackward),
        ("testResettableTrait", testResettableTrait),
        ("testClonableTrait", testClonableTrait),
        ("testPositionableTraitForwardDrain", testPositionableTraitForwardDrain),
        ("testPositionableTraitBackwardDrain", testPositionableTraitBackwardDrain),
    ]
}
