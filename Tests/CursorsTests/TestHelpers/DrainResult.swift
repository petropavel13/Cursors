import Cursors

struct DrainResult<Cursor: CursorType> {
    let pages: [[Cursor.Page.Item]]
    let error: Cursor.Failure?
}

extension DrainResult: Equatable where Cursor.Page.Item: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.error, rhs.error) {
        case (nil, nil):
            return lhs.pages == rhs.pages
        case let (firstRunCursorError?, secondRunCursorError?):
            return lhs.pages == rhs.pages
                && firstRunCursorError.isExhausted == secondRunCursorError.isExhausted
        default:
            return false
        }
    }
}
