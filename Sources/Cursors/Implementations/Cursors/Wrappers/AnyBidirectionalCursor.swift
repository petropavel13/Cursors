open class AnyBidirectionalCursor<Page: PageType, Failure: CursorErrorType>:
    AnyCursor<Page, Failure>, BidirectionalCursorType {

    private let loadPreviousPageClosure: (@escaping ResultCompletion) -> Void

    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        loadPreviousPageClosure(completion)
    }

    public init<Cursor: BidirectionalCursorType>(bidirectionalCursor: Cursor) where Cursor.Page == Page, Cursor.Failure == Failure {
        self.loadPreviousPageClosure = bidirectionalCursor.loadPreviousPage
        super.init(cursor: bidirectionalCursor)
    }
}

// MARK: - Operators

public extension BidirectionalCursorType {
    func eraseToAnyCursor() -> AnyBidirectionalCursor<Page, Failure> {
        return AnyBidirectionalCursor(bidirectionalCursor: self)
    }
}
