import Cursors

struct DrainResult<Cursor: CursorType> {
    let accumulatedElements: [Cursor.Element]
    let error: Cursor.Failure?
}

extension DrainResult where Cursor.Element: Equatable {
    func equals(to other: Self) -> Bool {
        switch (error, other.error) {
        case (nil, nil):
            return accumulatedElements == other.accumulatedElements
        case let (firstRunCursorError?, secondRunCursorError?):
            return accumulatedElements == other.accumulatedElements
                && firstRunCursorError.isExhausted == secondRunCursorError.isExhausted
        default:
            return false
        }
    }
}

extension CursorType {
    func drainForward(accumulatingResult: [Element] = [], completion: @escaping (DrainResult<Self>) -> Void) {
        loadNextPage {
            switch $0 {
            case let .success((elements, exhausted)):
                let overallResults = accumulatingResult + elements

                if exhausted {
                    completion(DrainResult(accumulatedElements: overallResults, error: nil))
                } else {
                    self.drainForward(accumulatingResult: overallResults,
                                      completion: completion)
                }
            case let .failure(cursorError):
                completion(DrainResult(accumulatedElements: accumulatingResult, error: cursorError))
            }
        }
    }
}
