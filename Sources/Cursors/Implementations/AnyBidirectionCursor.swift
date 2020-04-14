public final class AnyBidirectionCursor<Element, Failure: CursorErrorType>:
    AnyCursor<Element, Failure>, BidirectionCursorType {

    private let loadPreviousPageClosure: (@escaping ResultCompletion) -> Void

    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        loadPreviousPageClosure(completion)
    }

    public init<Cursor: BidirectionCursorType>(bidirectionCursor: Cursor) where Cursor.Element == Element, Cursor.Failure == Failure {
        self.loadPreviousPageClosure = bidirectionCursor.loadPreviousPage
        super.init(cursor: bidirectionCursor)
    }
}

// MARK: - Operators

public extension BidirectionCursorType {
    func eraseToAnyCursor() -> AnyBidirectionCursor<Element, Failure> {
        return AnyBidirectionCursor(bidirectionCursor: self)
    }
}
