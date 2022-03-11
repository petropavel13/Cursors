@available(iOS 13.0.0, *)
open class PageBasedAsyncClosureCursor<P: PageType, F: CursorErrorType>: CursorType, PositionableType, CancelableType {
    public typealias Page = P
    public typealias Failure = F

    public typealias FetchPageClosure = (Position) async -> LoadResult

    internal(set) public var currentPosition = 0

    private let nextPageClosure: FetchPageClosure

    var currentTask: Task<Void, Never>?

    public var movingForwardCurrentPosition: Int {
        get {
            currentPosition
        }
        set {
            currentPosition = newValue
        }
    }

    public init(nextPageClosure: @escaping FetchPageClosure) {
        self.nextPageClosure = nextPageClosure
    }

    public func loadNextPage(completion: @escaping ResultCompletion) {
        currentTask = Task {
            let result = await nextPageClosure(movingForwardCurrentPosition)

            if case .success = result {
                seek(to: movingForwardCurrentPosition.advanced(by: 1))
            }

            completion(result)
        }
    }

    public func seek(to position: Int) {
        currentPosition = position
    }

    public func cancel() {
        currentTask?.cancel()
    }
}
