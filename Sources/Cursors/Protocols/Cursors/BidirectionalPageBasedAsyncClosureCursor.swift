@available(iOS 13.0.0, *)
open class BidirectionalPageBasedAsyncClosureCursor<P: PageType, F: CursorErrorType>: PageBasedAsyncClosureCursor<P, F>, BidirectionalCursorType, BidirectionalPositionableType {

    private let previousPageClosure: FetchPageClosure

    public var movingBackwardCurrentPosition: Int {
        get {
            currentPosition
        }
        set {
            currentPosition = newValue
        }
    }

    public init(nextPageClosure: @escaping FetchPageClosure,
                previousPageClosure: @escaping FetchPageClosure) {

        self.previousPageClosure = previousPageClosure

        super.init(nextPageClosure: nextPageClosure)
    }

    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        currentTask = Task {
            let result = await previousPageClosure(movingBackwardCurrentPosition)

            if case .success = result {
                seek(to: movingBackwardCurrentPosition.advanced(by: -1))
            }

            completion(result)
        }
    }
}
