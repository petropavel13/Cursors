public final class CursorObserver<Cursor, EventHandler: CursorObserverEventHandler>: CursorType where EventHandler.Cursor == Cursor {

    public typealias Page = Cursor.Page
    public typealias Failure = Cursor.Failure

    private let cursor: Cursor
    let eventHandler: EventHandler

    public init(cursor: Cursor, eventHander: EventHandler) {
        self.cursor = cursor
        self.eventHandler = eventHander
    }

    // MARK: - CursorType

    public func loadNextPage(completion: @escaping ResultCompletion) {
        load(direction: .forward,
             nextPageClosure: { cursor.loadNextPage(completion: $0) },
             completion: completion)
    }

    // MARK: - Private

    private func load(direction: LoadDirection,
                      nextPageClosure: (@escaping ResultCompletion) -> Void,
                      completion: @escaping ResultCompletion) {

        eventHandler.onLoadStart(direction: direction)

        nextPageClosure {
            switch $0 {
            case let .success(successResult):
                self.eventHandler.onResult(successResult: successResult, direction: direction)
            case let .failure(failure):
                self.eventHandler.onError(failure: failure, direction: direction)
            }

            self.eventHandler.onFinish(direction: direction)

            completion($0)
        }
    }
}

// MARK: - Conditional conformances

extension CursorObserver: BidirectionalCursorType where Cursor: BidirectionalCursorType {
    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        load(direction: .backward,
             nextPageClosure: { cursor.loadPreviousPage(completion: $0) },
             completion: completion)
    }
}

extension CursorObserver: PositionableType where Cursor: PositionableType {
    public typealias Position = Cursor.Position

    public var movingForwardCurrentPosition: Position {
        return cursor.movingForwardCurrentPosition
    }

    public func seek(to position: Position) {
        cursor.seek(to: position)
    }
}

extension CursorObserver: BidirectionalPositionableType where Cursor: BidirectionalPositionableType {
    public var movingBackwardCurrentPosition: Position {
        return cursor.movingBackwardCurrentPosition
    }
}

extension CursorObserver: PagePositionableType where Cursor: PagePositionableType {
    public func position(after page: Position.PageIndex) -> Position? {
        return cursor.position(after: page)
    }

    public func position(before page: Position.PageIndex) -> Position? {
        return cursor.position(before: page)
    }
}

extension CursorObserver: ElementStrideableType where Cursor: ElementStrideableType {
    public func position(advancedBy stride: Position.ElementIndex.Stride) -> Position? {
        return cursor.position(advancedBy: stride)
    }
}

extension CursorObserver: CloneableType where Cursor: CloneableType {
    convenience public init(keepingStateOf other: CursorObserver<Cursor, EventHandler>) {
        self.init(cursor: other.cursor.clone(), eventHander: other.eventHandler.clone())
    }
}

extension CursorObserver: ResettableType where Cursor: ResettableType {
    convenience public init(withInitialStateFrom other: CursorObserver<Cursor, EventHandler>) {
        self.init(cursor: other.cursor.reset(), eventHander: other.eventHandler.reset())
    }
}

extension CursorObserver: CancelableType where Cursor: CancelableType {
    public func cancel() {
        cursor.cancel()
    }
}

// MARK: - Operators

public extension CursorType {
    func print() -> CursorObserver<Self, LogEventHandler<Self>> {
        return CursorObserver(cursor: self, eventHander: LogEventHandler { debugPrint($0) })
    }
}
