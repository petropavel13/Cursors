open class AnyCancelableCursor<Page: PageType, Failure: CursorErrorType>: AnyCursor<Page, Failure>, CancelableType {
    private let cancelClosure: () -> Void

    public init<Cursor: CancelableCursorType>(cancelableCursor: Cursor) where Cursor.Page == Page, Cursor.Failure == Failure {
        self.cancelClosure = cancelableCursor.cancel
        super.init(cursor: cancelableCursor)
    }

    // MARK: - CancelableType

    public func cancel() {
        cancelClosure()
    }
}

// MARK: - Operators

public extension CancelableCursorType {
    func eraseToAnyCursor() -> AnyCancelableCursor<Page, Failure> {
        return AnyCancelableCursor(cancelableCursor: self)
    }
}
