public final class LogEventHandler<Cursor: CursorType>: CursorObserverEventHandler {

    private let logClosure: (String) -> Void

    private static var cursorName: String {
        return String(describing: Cursor.self)
    }

    public init(keepingStateOf other: LogEventHandler<Cursor>) {
        self.logClosure = other.logClosure
    }

    public init(withInitialStateFrom other: LogEventHandler<Cursor>) {
        self.logClosure = other.logClosure
    }

    init(logClosure: @escaping (String) -> Void) {
        self.logClosure = logClosure
    }

    public func onLoadStart(direction: LoadDirection) {
        logClosure("Start loading from \(Self.cursorName) with \(direction) direction.")
    }

    public func onResult(successResult: Cursor.SuccessResult, direction: LoadDirection) {
        logClosure("Result received \(successResult) from \(Self.cursorName).")
    }

    public func onError(failure: Cursor.Failure, direction: LoadDirection) {
        logClosure("Got an error \(failure) from \(Self.cursorName) with \(direction) direction.")
    }

    public func onFinish(direction: LoadDirection) {
        logClosure("\(Self.cursorName) did finish loading with \(direction) direction.")
    }
}
