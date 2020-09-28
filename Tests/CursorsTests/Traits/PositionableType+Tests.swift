import Cursors
import XCTest

extension CursorType where Self: PositionableType, Page.Item: Equatable {

    func expectResults(after position: Position, equalsTo result: DrainResult<Self>) -> XCTestExpectation {
        return expectResults(drainedFrom: position,
                             equalsTo: result,
                             drainClosure: { self.drainForward(completion: $0) })
    }

    func expectResults(drainedFrom position: Position,
                       equalsTo result: DrainResult<Self>,
                       drainClosure: @escaping (@escaping DrainCompletion) -> Void) -> XCTestExpectation {

        let cursorType = type(of: self)

        let expectation = XCTestExpectation(description: "\(cursorType) drain from position expectation")

        seek(to: position)

        drainClosure {
            XCTAssertEqual($0, result)
            expectation.fulfill()
        }

        return expectation
    }
}

extension BidirectionalCursorType where Self: PositionableType, Page.Item: Equatable {
    func expectResults(before position: Position, equalsTo result: DrainResult<Self>) -> XCTestExpectation {
        return expectResults(drainedFrom: position,
                             equalsTo: result,
                             drainClosure: { self.drainBackward(completion: $0) })
    }
}
