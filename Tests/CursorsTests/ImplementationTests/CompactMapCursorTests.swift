import XCTest
@testable import Cursors

final class CompactMapCursorTests: BaseCursorTestCase<CompactMapCursor<SimpleStubCursor<[Int]>, [String]>> {
    private let defaultOriginalPages = [[1,2,3], [4,5]]

    override var defaultTestPages: [[String]] {
        return defaultOriginalPages.map { $0.map(defaultTransformClosure) }
    }

    private let defaultTransformClosure: (Int) -> String = { String($0) }

    private func createDefaultSimpleStubCursor(pages: [[Int]]) -> SimpleStubCursor<[Int]> {
        return SimpleStubCursor(pages: defaultOriginalPages)
    }

    override func createDefaultTestCursor(pages: [[String]]) -> CompactMapCursor<SimpleStubCursor<[Int]>, [String]> {
        return createDefaultSimpleStubCursor(pages: defaultOriginalPages).compactMap(transformClosure: defaultTransformClosure,
                                                                                     createPageClosure: { _, pageItems in pageItems })
    }

    func testOneDirectionFilterDrain() {
        let filterClosure: (Int) -> Bool = { $0.isMultiple(of: 2) }

        let compactMapCursor = createDefaultSimpleStubCursor(pages: defaultOriginalPages)
            .filter(filterClosure: filterClosure)

        let expectedPages = defaultOriginalPages.map { $0.filter(filterClosure) }

        let expectation = compactMapCursor.forwardResultEqual(to: DrainResult(pages: expectedPages, error: nil))

        wait(for: [expectation], timeout: 10)
    }

    // Stupid code to force Xcode execute parent tests

    func testResettableTrait() {
        super.baseTestResettableTrait()
    }

    func testClonableTrait() {
        super.baseTestClonableTrait()
    }

    static var allTests = [
        ("testOneDirectionDrainForward", testOneDirectionDrainForward),
        ("testOneDirectionFilterDrain", testOneDirectionFilterDrain),
        ("testResettableTrait", testResettableTrait),
        ("testClonableTrait", testClonableTrait),
    ]
}
