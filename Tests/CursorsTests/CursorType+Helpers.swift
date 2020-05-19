import Cursors

struct DrainResult<Cursor: CursorType> {
    let pages: [[Cursor.Element]]
    let error: Cursor.Failure?
}

extension DrainResult: Equatable where Cursor.Element: Equatable {
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

extension CursorType {
    func drainForward(accumulatingResult: [[Element]] = [], completion: @escaping (DrainResult<Self>) -> Void) {
        loadNextPage {
            switch $0 {
            case let .success((elements, exhausted)):
                let overallResults = accumulatingResult + [elements]

                if exhausted {
                    completion(DrainResult(pages: overallResults, error: nil))
                } else {
                    self.drainForward(accumulatingResult: overallResults,
                                      completion: completion)
                }
            case let .failure(cursorError):
                completion(DrainResult(pages: accumulatingResult, error: cursorError))
            }
        }
    }
}
