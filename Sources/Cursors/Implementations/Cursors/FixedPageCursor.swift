public final class FixedPageCursor<Cursor: CursorType>: CursorType {
    public typealias Element = Cursor.Element
    public typealias Failure = Cursor.Failure

    private final class Buffer: CloneableType {
        typealias LastResult = (successResult: SuccessResult, direction: LoadDirection)

        private static var emptyResult: LastResult {
            return (successResult: (elements: [], exhausted: false), direction: .forward)
        }

        private var lastResult: LastResult

        private var elements: [Element] {
            get {
                return lastResult.successResult.elements
            }
            set {
                lastResult.successResult.elements = newValue
            }
        }

        convenience init() {
            self.init(lastResult: Self.emptyResult)
        }

        init(lastResult: LastResult) {
            self.lastResult = lastResult
        }

        convenience init(keepingStateOf other: Buffer) {
            self.init(lastResult: other.lastResult)
        }

        func canDrain(pageSize: Int, in direction: LoadDirection) -> Bool {
            guard lastResult.direction == direction else {
                return false
            }

            return lastResult.successResult.elements.count >= pageSize
        }

        func drain(in direction: LoadDirection, pageSize: Int = .max) -> LoadResult {
            guard lastResult.direction == direction else {
                return .success((elements: [], exhausted: true))
            }

            let numberOfItemsToDeliver = Swift.min(elements.count, pageSize)

            let newItems = direction == .forward
                ? elements.prefix(upTo: numberOfItemsToDeliver)
                : elements.suffix(numberOfItemsToDeliver)

            direction == .forward
                ? elements.removeFirst(numberOfItemsToDeliver)
                : elements.removeLast(numberOfItemsToDeliver)

            guard !newItems.isEmpty else {
                return .failure(.exhaustedError)
            }

            return .success((elements: Array(newItems), exhausted: lastResult.successResult.exhausted && elements.isEmpty))
        }

        func fill(from result: SuccessResult, direction: LoadDirection) {
            if lastResult.direction == direction {
                let newElements = direction == .forward
                    ? elements + result.elements
                    : result.elements + elements
                let successResult = (elements: newElements, exhausted: result.exhausted)
                lastResult = (successResult: successResult, direction: direction)
            } else {
                lastResult = (direction: direction, successResult: result)
            }
        }

        func clear() {
            lastResult = Self.emptyResult
        }
    }

    private let cursor: Cursor
    private let pageSize: Int

    private let buffer = Buffer()

    public init(cursor: Cursor, pageSize: Int) {
        self.cursor = cursor
        self.pageSize = pageSize
    }

    private func load(nextPageClosure: @escaping (@escaping ResultCompletion) -> Void,
                      cursorNextPageClosure: (@escaping ResultCompletion) -> Void,
                      direction: LoadDirection,
                      completion: @escaping ResultCompletion) {

        if buffer.canDrain(pageSize: pageSize, in: direction) {
            completion(buffer.drain(in: direction, pageSize: pageSize))
        } else {
            cursorNextPageClosure {
                switch $0 {
                case let .success(result):
                    self.buffer.fill(from: result, direction: direction)

                    nextPageClosure(completion)
                case let .failure(failure):
                    if failure.isExhausted {
                        completion(self.buffer.drain(in: direction))
                    } else {
                        completion($0)
                    }
                }
            }
        }
    }

    public func loadNextPage(completion: @escaping ResultCompletion) {
        load(nextPageClosure: loadNextPage,
             cursorNextPageClosure: cursor.loadNextPage,
             direction: .forward,
             completion: completion)
    }
}

// MARK: - Conditional conformances

extension FixedPageCursor: BidirectionalCursorType where Cursor: BidirectionalCursorType {
    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        load(nextPageClosure: loadPreviousPage,
             cursorNextPageClosure: cursor.loadPreviousPage,
             direction: .backward,
             completion: completion)
    }
}

extension FixedPageCursor: PositionableType where Cursor: PositionableType {
    public typealias Position = Cursor.Position

    public var movingForwardCurrentPosition: Position {
        return cursor.movingForwardCurrentPosition
    }

    public func seek(to position: Position) {
        buffer.clear()
        cursor.seek(to: position)
    }
}

extension FixedPageCursor: BidirectionalPositionableType where Cursor: BidirectionalPositionableType {
    public var movingForwardCurrentPosition: Position {
        return cursor.movingForwardCurrentPosition
    }

    public var movingBackwardCurrentPosition: Position {
        return cursor.movingBackwardCurrentPosition
    }
}

extension FixedPageCursor: PagePositionableType where Cursor: PagePositionableType {
    public func position(after page: Position.Page) -> Position? {
        return cursor.position(after: page)
    }

    public func position(before page: Position.Page) -> Position? {
        return cursor.position(before: page)
    }
}

extension FixedPageCursor: ElementStrideableType where Cursor: ElementStrideableType {
    public func position(advancedBy stride: Position.Element.Stride) -> Position? {
        return cursor.position(advancedBy: stride)
    }
}

extension FixedPageCursor: ResettableType where Cursor: ResettableType {
    public convenience init(withInitialStateFrom other: FixedPageCursor<Cursor>) {
        self.init(cursor: other.cursor.reset(), pageSize: other.pageSize)
    }
}

extension FixedPageCursor: CloneableType where Cursor: CloneableType {
    public convenience init(keepingStateOf other: FixedPageCursor<Cursor>) {
        self.init(cursor: other.cursor.clone(), pageSize: other.pageSize)
    }
}

// MARK: - Operators

public extension CursorType {
    func paged(by pageSize: Int) -> FixedPageCursor<Self> {
        return FixedPageCursor(cursor: self, pageSize: pageSize)
    }
}
