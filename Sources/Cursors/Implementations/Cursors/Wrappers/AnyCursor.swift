open class AnyCursor<Page: PageType, Failure: CursorErrorType>: CursorType {
    public typealias Page = Page
    public typealias Failure = Failure

    private let loadNextPageClosure: (@escaping ResultCompletion) -> Void

    public init<Cursor: CursorType>(cursor: Cursor) where Cursor.Page == Page, Cursor.Failure == Failure {
        self.loadNextPageClosure = cursor.loadNextPage
    }

    // MARK: - CursorType

    public func loadNextPage(completion: @escaping ResultCompletion) {
        loadNextPageClosure(completion)
    }
}

// MARK: - Operators

public extension CursorType {
    func eraseToAnyCursor() -> AnyCursor<Page, Failure> {
        return AnyCursor(cursor: self)
    }
}
