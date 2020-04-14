public struct ExhaustedCursorError: CursorErrorType {
    public let isExhausted = true

    public static var exhausted: ExhaustedCursorError {
        return ExhaustedCursorError()
    }
}
