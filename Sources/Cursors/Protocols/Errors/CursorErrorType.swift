public protocol CursorErrorType: Error {
    var isExhausted: Bool { get }

    static var exhaustedError: Self { get }
}
