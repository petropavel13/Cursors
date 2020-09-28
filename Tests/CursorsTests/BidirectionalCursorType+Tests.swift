import Cursors
import XCTest

extension BidirectionalCursorType where Page.Item: Equatable {
    func backwardResultEqual(to result: DrainResult<Self>) -> XCTestExpectation {
        return drainResultEqual(to: result,
                                drainClosure: { self.drainBackward(completion: $0) },
                                nextPageClosure: { self.loadPreviousPage(completion: $0) })
    }
}
