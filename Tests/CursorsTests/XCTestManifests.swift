import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SimpleStubCursorTests.allTests),
        testCase(StubCursorTests.allTests),
        testCase(CompactMapCursorTests.allTests),
    ]
}
#endif
