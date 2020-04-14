import XCTest
@testable import Cursors

final class SimpleStubCursorTests: XCTestCase {
    func testOneDirectionDrain() {
        let pages = [[1,2,3],[4,5]]

        let stubCursor = SimpleStubCursor(pages: pages)

        wait(for: stubCursor.testPagesEqual(to: pages), timeout: 10)
    }

    static var allTests = [
        ("testOneDirectionDrain", testOneDirectionDrain),
    ]
}
