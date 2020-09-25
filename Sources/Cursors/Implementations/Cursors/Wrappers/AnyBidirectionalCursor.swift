open class AnyBidirectionalCursor<Element, Failure: CursorErrorType>:
    AnyCursor<Element, Failure>, BidirectionalCursorType {

    private let loadPreviousPageClosure: (@escaping ResultCompletion) -> Void

    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        loadPreviousPageClosure(completion)
    }

    public init<Cursor: BidirectionalCursorType>(bidirectionalCursor: Cursor) where Cursor.Element == Element, Cursor.Failure == Failure {
        self.loadPreviousPageClosure = bidirectionalCursor.loadPreviousPage
        super.init(cursor: bidirectionalCursor)
    }
}

// MARK: - Operators

public extension BidirectionalCursorType {
    func eraseToAnyCursor() -> AnyBidirectionalCursor<Element, Failure> {
        return AnyBidirectionalCursor(bidirectionalCursor: self)
    }
}
