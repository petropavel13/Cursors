public protocol CancelableCursorType: CursorType, CancelableType where Failure: CancelableCursorErrorType {}
