public struct ExhaustedCursorError: CursorErrorType {
    public let isExhausted = true

    public static var exhaustedError: ExhaustedCursorError {
        return ExhaustedCursorError()
    }
}
