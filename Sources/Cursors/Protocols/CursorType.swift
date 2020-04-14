public protocol CursorType {
    associatedtype Element
    associatedtype Failure: CursorErrorType

    typealias SuccessResult = (elements: [Element], exhausted: Bool)
    typealias ResultCompletion = (Result<SuccessResult, Failure>) -> Void

    func loadNextPage(completion: @escaping ResultCompletion)
}
