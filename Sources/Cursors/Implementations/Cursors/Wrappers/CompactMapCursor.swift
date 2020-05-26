public final class CompactMapCursor<Cursor: CursorType, Element>: CursorType {
    public typealias Element = Element
    public typealias Failure = Cursor.Failure

    private let cursor: Cursor
    private let transformClosure: TransformClosure

    public typealias TransformClosure = (Cursor.Element) -> Element?

    public init(cursor: Cursor, transformClosure: @escaping TransformClosure) {
        self.cursor = cursor
        self.transformClosure = transformClosure
    }

    public func loadNextPage(completion: @escaping ResultCompletion) {
        load(nextPageClosure: cursor.loadNextPage, completion: completion)
    }

    private func load(nextPageClosure: (@escaping Cursor.ResultCompletion) -> Void, completion: @escaping ResultCompletion) {
        nextPageClosure {
            switch $0 {
            case let .success(result):
                let transformedNewItems = result.elements.compactMap(self.transformClosure)

                completion(.success((elements: transformedNewItems, exhausted: result.exhausted)))
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }
}

// MARK: - Conditional conformances

extension CompactMapCursor: BidirectionalCursorType where Cursor: BidirectionalCursorType {
    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        load(nextPageClosure: cursor.loadPreviousPage, completion: completion)
    }
}

extension CompactMapCursor: PositionableType where Cursor: PositionableType {
    public typealias Position = Cursor.Position

    public var movingForwardCurrentPosition: Position {
        return cursor.movingForwardCurrentPosition
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

extension CompactMapCursor: PagePositionableType where Cursor: PagePositionableType {
    public func position(after page: Position.Page) -> Position? {
        return cursor.position(after: page)
    }

    public func position(before page: Position.Page) -> Position? {
        return cursor.position(before: page)
    }
}

extension CompactMapCursor: ElementStrideableType where Cursor: ElementStrideableType {
    public func position(advancedBy stride: Position.Element.Stride) -> Position? {
        return cursor.position(advancedBy: stride)
    }
}

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

// MARK: - Operators

public extension CursorType {
    func compactMap<T>(transformClosure: @escaping CompactMapCursor<Self, T>.TransformClosure) -> CompactMapCursor<Self, T> {
        return CompactMapCursor(cursor: self, transformClosure: transformClosure)
    }

    func filter(filterClosure: @escaping (Element) -> Bool) -> CompactMapCursor<Self, Element> {
        return CompactMapCursor(cursor: self) { filterClosure($0) ? $0 : nil }
    }
}
