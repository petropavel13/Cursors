public enum CancelableCursorError: CancelableCursorErrorType {

    case exhausted
    case cancelled

    public var isExhausted: Bool {
        self == .exhausted
    }

    public var isCancelled: Bool {
        self == .cancelled
    }

    public static var exhaustedError: Self {
        .exhausted
    }

    public static var cancelledError: Self {
        .cancelled
    }
}
