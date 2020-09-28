import Cursors

extension CursorType {
    typealias DrainCompletion = (DrainResult<Self>) -> Void

    func drain(nextPageClosure: @escaping (@escaping ResultCompletion) -> Void,
               accumulatingResult: [[Page.Item]] = [],
               completion: @escaping DrainCompletion) {

        nextPageClosure {
            switch $0 {
            case let .success((elements, exhausted)):
                let overallResults = accumulatingResult + [elements.pageItems]

                if exhausted {
                    completion(DrainResult(pages: overallResults, error: nil))
                } else {
                    self.drain(nextPageClosure: nextPageClosure,
                               accumulatingResult: overallResults,
                               completion: completion)
                }
            case let .failure(cursorError):
                completion(DrainResult(pages: accumulatingResult, error: cursorError))
            }
        }
    }

    func drainForward(completion: @escaping DrainCompletion) {
        drain(nextPageClosure: { self.loadNextPage(completion: $0) }, completion: completion)
    }
}
