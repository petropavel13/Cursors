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

extension CompactMapCursor: ClonableType where Cursor: ClonableType {
    public convenience init(keepingStateOf other: CompactMapCursor<Cursor, Element>) {
        self.init(cursor: other.cursor.clone(), transformClosure: other.transformClosure)
    }
}

extension CompactMapCursor: SeekableType where Cursor: SeekableType {
    public typealias Position = Cursor.Position

    public var initialPosition: Position {
        return cursor.initialPosition
    }

    public func seek(to position: Position) {
        cursor.seek(to: position)
    }
}

extension CompactMapCursor: SkipableType where Cursor: SkipableType {
    public func skip(pages: Int) {
        cursor.skip(pages: pages)
    }
}

extension CompactMapCursor: BidirectionCursorType where Cursor: BidirectionCursorType {
    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        return cursor.loadPreviousPage {
            self.handle(result: $0, completion: completion)
        }
    }
}

// MARK: - Operators

public extension CursorType {
    func flatMap<T>(transformClosure: @escaping CompactMapCursor<Self, T>.TransformClosure) -> CompactMapCursor<Self, T> {
        return CompactMapCursor(cursor: self, transformClosure: transformClosure)
    }

    func filter(filterClosure: @escaping (Element) -> Bool) -> CompactMapCursor<Self, Element> {
        return CompactMapCursor(cursor: self) { filterClosure($0) ? $0 : nil }
    }
}
