public final class FixedPageCursor<Cursor: CursorType>: CursorType {
    public typealias Page = Cursor.Page
    public typealias Failure = Cursor.Failure

    private final class Buffer: CloneableType {
        typealias LastResult = (successResult: SuccessResult, direction: LoadDirection)

        private var lastResult: LastResult

        private var elements: [Page.Item] {
            return lastResult.successResult.page.pageItems
        }

        private func copyPage(with items: [Page.Item]) -> Page {
            return Page(copy: lastResult.successResult.page, pageItems: items)
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

            return elements.count >= pageSize
        }

        func drain(in direction: LoadDirection, pageSize: Int = .max) -> LoadResult {
            guard lastResult.direction == direction else {
                return .success((page: copyPage(with: []), exhausted: true))
            }

            let numberOfItemsToDeliver = Swift.min(elements.count, pageSize)

            let newItems = direction == .forward
                ? elements.prefix(upTo: numberOfItemsToDeliver)
                : elements.suffix(numberOfItemsToDeliver)

            var newBufferItems = elements

            direction == .forward
                ? newBufferItems.removeFirst(numberOfItemsToDeliver)
                : newBufferItems.removeLast(numberOfItemsToDeliver)

            lastResult.successResult.page = copyPage(with: newBufferItems)

            guard !newItems.isEmpty else {
                return .failure(.exhaustedError)
            }

            return .success((page: copyPage(with: Array(newItems)),
                                        exhausted: lastResult.successResult.exhausted && elements.isEmpty))
        }

        func fill(from result: SuccessResult, direction: LoadDirection) {
            if lastResult.direction == direction {
                let newElements = direction == .forward
                    ? elements + result.page.pageItems
                    : result.page.pageItems + elements

                let successResult = (page: copyPage(with: newElements), exhausted: result.exhausted)

                lastResult = (successResult: successResult, direction: direction)
            } else {
                lastResult = (successResult: result, direction: direction)
            }
        }
    }

    private let cursor: Cursor
    private let pageSize: Int

    private var buffer: Buffer?

    public init(cursor: Cursor, pageSize: Int) {
        self.cursor = cursor
        self.pageSize = pageSize
    }

    // MARK: - CursorType

    public func loadNextPage(completion: @escaping ResultCompletion) {
        load(nextPageClosure: loadNextPage,
             cursorNextPageClosure: cursor.loadNextPage,
             direction: .forward,
             completion: completion)
    }

    // MARK: - Private

    private func load(nextPageClosure: @escaping (@escaping ResultCompletion) -> Void,
                      cursorNextPageClosure: (@escaping ResultCompletion) -> Void,
                      direction: LoadDirection,
                      completion: @escaping ResultCompletion) {

        if let buffer = buffer, buffer.canDrain(pageSize: pageSize, in: direction) {
            completion(buffer.drain(in: direction, pageSize: pageSize))
        } else {
            cursorNextPageClosure {
                switch $0 {
                case let .success(result):
                    if let buffer = self.buffer {
                        buffer.fill(from: result, direction: direction)
                    } else {
                        self.buffer = Buffer(lastResult: (successResult: result, direction: direction))
                    }

                    nextPageClosure(completion)
                case let .failure(failure):
                    if failure.isExhausted {
                        if let buffer = self.buffer {
                            completion(buffer.drain(in: direction))
                        } else {
                            completion(.failure(failure))
                        }
                    } else {
                        completion($0)
                    }
                }
            }
        }
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
        buffer = nil
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
    public func position(after page: Position.PageIndex) -> Position? {
        return cursor.position(after: page)
    }

    public func position(before page: Position.PageIndex) -> Position? {
        return cursor.position(before: page)
    }
}

extension FixedPageCursor: ElementStrideableType where Cursor: ElementStrideableType {
    public func position(advancedBy stride: Position.ElementIndex.Stride) -> Position? {
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

extension FixedPageCursor: CancelableType where Cursor: CancelableType {
    public func cancel() {
        cursor.cancel()
    }
}

// MARK: - Operators

public extension CursorType {
    func paged(by pageSize: Int) -> FixedPageCursor<Self> {
        return FixedPageCursor(cursor: self, pageSize: pageSize)
    }
}
