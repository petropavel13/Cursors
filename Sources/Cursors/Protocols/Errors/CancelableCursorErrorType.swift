public protocol CancelableCursorErrorType: CursorErrorType {
    var isCancelled: Bool { get }

    static var cancelledError: Self { get }
}
