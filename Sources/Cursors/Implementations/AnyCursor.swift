public class AnyCursor<Element, Failure: CursorErrorType>: CursorType {
    public typealias Element = Element
    public typealias Failure = Failure

    private let loadNextPageClosure: (@escaping ResultCompletion) -> Void

    public func loadNextPage(completion: @escaping ResultCompletion) {
        loadNextPageClosure(completion)
    }

    public init<Cursor: CursorType>(cursor: Cursor) where Cursor.Element == Element, Cursor.Failure == Failure {
        self.loadNextPageClosure = cursor.loadNextPage
    }
}

// MARK: - Operators

public extension CursorType {
    func eraseToAnyCursor() -> AnyCursor<Element, Failure> {
        return AnyCursor(cursor: self)
    }
}