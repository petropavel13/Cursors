import XCTest
@testable import Cursors

final class CompactMapCursorTests: XCTestCase {
    private let defaultTestPages = [[1,2,3], [4,5]]

    private func createDefaultSimpleStubCursor() -> SimpleStubCursor<Int> {
        return SimpleStubCursor(pages: defaultTestPages)
    }

    func testOneDirectionTransformDrain() {
        let transformClosure: (Int) -> String = { String($0) }

        let compactMapCursor = createDefaultSimpleStubCursor()
            .compactMap(transformClosure: transformClosure)

        let expectedPages = defaultTestPages.map { $0.compactMap(transformClosure) }

        wait(for: compactMapCursor.testPagesEqual(to: expectedPages), timeout: 10)
    }

    func testOneDirectionFilterDrain() {
        let filterClosure: (Int) -> Bool = { $0.isMultiple(of: 2) }

        let compactMapCursor = createDefaultSimpleStubCursor()
            .filter(filterClosure: filterClosure)

        let expectedPages = defaultTestPages.map { $0.filter(filterClosure) }

        wait(for: compactMapCursor.testPagesEqual(to: expectedPages), timeout: 10)
    }

    func testResettableType() {
        let filterClosure: (Int) -> Bool = { $0.isMultiple(of: 2) }

        let compactMapCursor = createDefaultSimpleStubCursor()
            .filter(filterClosure: filterClosure)

        let expectation = compactMapCursor.testForwardResultsAreEqualAfterReset()

        wait(for: [expectation], timeout: 10)
    }

    static var allTests = [
        ("testOneDirectionTransformDrain", testOneDirectionTransformDrain),
        ("testOneDirectionFilterDrain", testOneDirectionFilterDrain),
        ("testResettableType", testResettableType),
    ]
}
