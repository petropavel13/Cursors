public protocol CursorType {
    associatedtype Element
    associatedtype Failure: CursorErrorType

    typealias SuccessResult = (elements: [Element], exhausted: Bool)
    typealias LoadResult = Result<SuccessResult, Failure>
    typealias ResultCompletion = (LoadResult) -> Void

    func loadNextPage(completion: @escaping ResultCompletion)
}
