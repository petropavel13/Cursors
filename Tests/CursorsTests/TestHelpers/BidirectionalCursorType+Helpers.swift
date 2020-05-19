import Cursors

extension BidirectionalCursorType {
    func drainBackward(completion: @escaping (DrainResult<Self>) -> Void) {
        drain(nextPageClosure: { self.loadPreviousPage(completion: $0) }, completion: completion)
    }
}
