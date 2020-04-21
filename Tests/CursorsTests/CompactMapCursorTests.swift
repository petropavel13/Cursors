import XCTest
@testable import Cursors

final class CompactMapCursorTests: XCTestCase {
    func testOneDirectionTransformDrain() {
        let pages = [[1,2,3],[4,5]]

        let transformClosure: (Int) -> String = { String($0) }

        let flatMapCursor = SimpleStubCursor(pages: pages)
            .compactMap(transformClosure: transformClosure)

        let expectedPages = pages.map { $0.compactMap(transformClosure) }

        wait(for: flatMapCursor.testPagesEqual(to: expectedPages), timeout: 10)
    }

    func testOneDirectionFilterDrain() {
        let pages = [[1,2,3],[4,5]]

        let filterClosure: (Int) -> Bool = { $0.isMultiple(of: 2) }

        let flatMapCursor = SimpleStubCursor(pages: pages)
            .filter(filterClosure: filterClosure)

        let expectedPages = pages.map { $0.filter(filterClosure) }

        wait(for: flatMapCursor.testPagesEqual(to: expectedPages), timeout: 10)
    }

    static var allTests = [
        ("testOneDirectionTransformDrain", testOneDirectionTransformDrain),
        ("testOneDirectionFilterDrain", testOneDirectionFilterDrain),
    ]
}
