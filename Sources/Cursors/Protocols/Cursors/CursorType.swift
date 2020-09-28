public protocol CursorType {
    associatedtype Page: PageType
    associatedtype Failure: CursorErrorType

    typealias SuccessResult = (page: Page, exhausted: Bool)
    typealias LoadResult = Result<SuccessResult, Failure>
    typealias ResultCompletion = (LoadResult) -> Void

    func loadNextPage(completion: @escaping ResultCompletion)
}
