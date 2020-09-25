open class AnyCancelableCursor<Element, Failure: CursorErrorType>: AnyCursor<Element, Failure>, CancelableType {
    private let cancelClosure: () -> Void

    public init<Cursor: CancelableCursorType>(cancelableCursor: Cursor) where Cursor.Element == Element, Cursor.Failure == Failure {
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
    func eraseToAnyCursor() -> AnyCancelableCursor<Element, Failure> {
        return AnyCancelableCursor(cancelableCursor: self)
    }
}
