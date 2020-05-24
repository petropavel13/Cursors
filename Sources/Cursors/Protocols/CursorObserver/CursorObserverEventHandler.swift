public protocol CursorObserverEventHandler: ResettableType, CloneableType {
    associatedtype Cursor: CursorType

    func onLoadStart(direction: LoadDirection)
    func onResult(successResult: Cursor.SuccessResult, direction: LoadDirection)
    func onError(failure: Cursor.Failure, direction: LoadDirection)
    func onFinish(direction: LoadDirection)
}
