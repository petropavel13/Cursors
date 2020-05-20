public final class CompactMapCursor<Cursor: CursorType, Element>: CursorType {
    public typealias Element = Element
    public typealias Failure = Cursor.Failure

    fileprivate let cursor: Cursor
    fileprivate let transformClosure: TransformClosure

    public typealias TransformClosure = (Cursor.Element) -> Element?

    public init(cursor: Cursor, transformClosure: @escaping TransformClosure) {
        self.cursor = cursor
        self.transformClosure = transformClosure
    }

    public func loadNextPage(completion: @escaping ResultCompletion) {
        return cursor.loadNextPage {
            self.handle(result: $0, completion: completion)
        }
    }

    private func handle(result: Result<Cursor.SuccessResult, Cursor.Failure>, completion: ResultCompletion) {
        switch result {
        case let .success(result):
            let transformedNewItems = result.elements.compactMap(self.transformClosure)

            completion(.success((elements: transformedNewItems, exhausted: result.exhausted)))
        case let .failure(failure):
            completion(.failure(failure))
        }
    }
}

// MARK: - Conditional conformances

extension CompactMapCursor: ResettableType where Cursor: ResettableType {
    public convenience init(withInitialStateFrom other: CompactMapCursor<Cursor, Element>) {
        self.init(cursor: other.cursor.reset(), transformClosure: other.transformClosure)
    }
}

extension CompactMapCursor: CloneableType where Cursor: CloneableType {
    public convenience init(keepingStateOf other: CompactMapCursor<Cursor, Element>) {
        self.init(cursor: other.cursor.clone(), transformClosure: other.transformClosure)
    }
}

extension CompactMapCursor: PositionableType where Cursor: PositionableType {
    public typealias Position = Cursor.Position

    public var currentPosition: Position {
        return cursor.currentPosition
    }

    public func seek(to position: Position) {
        cursor.seek(to: position)
    }
}

extension CompactMapCursor: BidirectionalPositionableType where Cursor: BidirectionalPositionableType {
    public var movingForwardCurrentPosition: Position {
        return cursor.movingForwardCurrentPosition
    }

    public var movingBackwardCurrentPosition: Position {
        return cursor.movingBackwardCurrentPosition
    }
}

extension CompactMapCursor: BidirectionalCursorType where Cursor: BidirectionalCursorType {
    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        return cursor.loadPreviousPage {
            self.handle(result: $0, completion: completion)
        }
    }
}

// MARK: - Operators

public extension CursorType {
    func compactMap<T>(transformClosure: @escaping CompactMapCursor<Self, T>.TransformClosure) -> CompactMapCursor<Self, T> {
        return CompactMapCursor(cursor: self, transformClosure: transformClosure)
    }

    func filter(filterClosure: @escaping (Element) -> Bool) -> CompactMapCursor<Self, Element> {
        return CompactMapCursor(cursor: self) { filterClosure($0) ? $0 : nil }
    }
}
