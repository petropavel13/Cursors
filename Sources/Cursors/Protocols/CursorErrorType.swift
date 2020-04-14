public protocol CursorErrorType: Error {
    var isExhausted: Bool { get }

    static var exhausted: Self { get }
}
