public final class CompactMapCursor<Cursor: CursorType, Page: PageType>: CursorType {
    public typealias Page = Page
    public typealias Failure = Cursor.Failure

    private let cursor: Cursor
    private let transformClosure: TransformClosure
    private let createPageClosure: CreatePageClosure

    public typealias TransformClosure = (Cursor.Page.Item) -> Page.Item?
    public typealias CreatePageClosure = (Cursor.Page, [Page.Item]) -> Page

    public init(cursor: Cursor,
                transformClosure: @escaping TransformClosure,
                createPageClosure: @escaping CreatePageClosure) {
        self.cursor = cursor
        self.transformClosure = transformClosure
        self.createPageClosure = createPageClosure
    }

    // MARK: - CursorType

    public func loadNextPage(completion: @escaping ResultCompletion) {
        load(nextPageClosure: cursor.loadNextPage, completion: completion)
    }

    // MARK: - Private

    private func load(nextPageClosure: (@escaping Cursor.ResultCompletion) -> Void, completion: @escaping ResultCompletion) {
        nextPageClosure {
            switch $0 {
            case let .success(result):
                let transformedNewItems = result.page.pageItems.compactMap(self.transformClosure)

                completion(.success((page: self.createPageClosure(result.page, transformedNewItems),
                                     exhausted: result.exhausted)))
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
    public func position(after page: Position.PageIndex) -> Position? {
        return cursor.position(after: page)
    }

    public func position(before page: Position.PageIndex) -> Position? {
        return cursor.position(before: page)
    }
}

extension CompactMapCursor: ElementStrideableType where Cursor: ElementStrideableType {
    public func position(advancedBy stride: Position.ElementIndex.Stride) -> Position? {
        return cursor.position(advancedBy: stride)
    }
}

extension CompactMapCursor: ResettableType where Cursor: ResettableType {
    public convenience init(withInitialStateFrom other: CompactMapCursor<Cursor, Page>) {
        self.init(cursor: other.cursor.reset(),
                  transformClosure: other.transformClosure,
                  createPageClosure: other.createPageClosure)
    }
}

extension CompactMapCursor: CloneableType where Cursor: CloneableType {
    public convenience init(keepingStateOf other: CompactMapCursor<Cursor, Page>) {
        self.init(cursor: other.cursor.clone(),
                  transformClosure: other.transformClosure,
                  createPageClosure: other.createPageClosure)
    }
}

extension CompactMapCursor: CancelableType where Cursor: CancelableType {
    public func cancel() {
        cursor.cancel()
    }
}

// MARK: - Operators

public extension CursorType {
    func compactMap<T>(transformClosure: @escaping CompactMapCursor<Self, T>.TransformClosure,
                       createPageClosure: @escaping CompactMapCursor<Self, T>.CreatePageClosure) -> CompactMapCursor<Self, T> {

        return CompactMapCursor(cursor: self,
                                transformClosure: transformClosure,
                                createPageClosure: createPageClosure)
    }

    func compactMap<T>(transformClosure: @escaping CompactMapCursor<Self, [T]>.TransformClosure) -> CompactMapCursor<Self, [T]> {

        return CompactMapCursor(cursor: self,
                                transformClosure: transformClosure,
                                createPageClosure: { _, newItems in newItems })
    }

    func filter(filterClosure: @escaping (Page.Item) -> Bool) -> CompactMapCursor<Self, Page> {

        return CompactMapCursor(cursor: self,
                                transformClosure: { filterClosure($0) ? $0 : nil },
                                createPageClosure: Page.init)
    }
}
