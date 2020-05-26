public final class CacheCursor<Cursor: CursorType & PagePositionableType, CacheStorage: CacheStorageType>: CursorType
    where CacheStorage.Page == Cursor.Position.Page, CacheStorage.PageContent == Cursor.SuccessResult {

    public typealias Element = Cursor.Element
    public typealias Failure = Cursor.Failure

    private let cursor: Cursor

    private var storage: CacheStorage

    public init(cursor: Cursor, storage: CacheStorage) {
        self.cursor = cursor
        self.storage = storage
    }

    public func loadNextPage(completion: @escaping ResultCompletion) {
        load(page: cursor.movingForwardCurrentPosition.pageIndex,
             direction: .forward,
             newCursorPositionGenerator: cursor.position(after:),
             nextPageClosure: { self.cursor.loadNextPage(completion: $0) },
             completion: completion)
    }

    public func clear() {
         // storage can be shared, so we need create a clear one
        storage = storage.reset()
         // CacheStorage implementation can drop persistent data, so we need to call it clear method
        storage.clear(completion: nil)
    }

    private func load(page: Cursor.Position.Page,
                      direction: LoadDirection,
                      newCursorPositionGenerator: @escaping (Cursor.Position.Page) -> Cursor.Position?,
                      nextPageClosure: @escaping (@escaping Cursor.ResultCompletion) -> Void,
                      completion: @escaping ResultCompletion) {

        let request = CacheStorage.Request(page: page, direction: direction)

        storage.loadPageContent(for: request) {
            if let pageContent = $0 {
                if let newPostion = newCursorPositionGenerator(page) {
                    self.cursor.seek(to: newPostion)
                }

                completion(.success(pageContent))
            } else {
                nextPageClosure {
                    switch $0 {
                    case let .success(pageContent):
                        if !pageContent.exhausted {
                            self.storage.save(pageContent: pageContent, for: request, completion: nil)
                        }

                        completion(.success(pageContent))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

// MARK: - Conditional conformances

extension CacheCursor: BidirectionalCursorType where Cursor: BidirectionalCursorType & BidirectionalPositionableType {
    public func loadPreviousPage(completion: @escaping ResultCompletion) {
        load(page: cursor.movingBackwardCurrentPosition.pageIndex,
             direction: .backward,
             newCursorPositionGenerator: cursor.position(before:),
             nextPageClosure: { self.cursor.loadPreviousPage(completion: $0) },
             completion: completion)
    }
}

extension CacheCursor: PositionableType where Cursor: PositionableType {
    public typealias Position = Cursor.Position

    public var movingForwardCurrentPosition: Position {
        return cursor.movingForwardCurrentPosition
    }

    public func seek(to position: Position) {
        cursor.seek(to: position)
    }
}

extension CacheCursor: BidirectionalPositionableType where Cursor: BidirectionalPositionableType {
    public var movingBackwardCurrentPosition: Position {
        return cursor.movingBackwardCurrentPosition
    }
}

extension CacheCursor: PagePositionableType where Cursor: PagePositionableType {
    public func position(after page: Position.Page) -> Position? {
        return cursor.position(after: page)
    }

    public func position(before page: Position.Page) -> Position? {
        return cursor.position(before: page)
    }
}

extension CacheCursor: ElementStrideableType where Cursor: ElementStrideableType {
    public func position(advancedBy stride: Position.Element.Stride) -> Position? {
        return cursor.position(advancedBy: stride)
    }
}

extension CacheCursor: ResettableType where Cursor: ResettableType {
    convenience public init(withInitialStateFrom other: CacheCursor<Cursor, CacheStorage>) {
        self.init(cursor: other.cursor.reset(), storage: other.storage.reset())
    }
}

extension CacheCursor: CloneableType where Cursor: CloneableType {
    convenience public init(keepingStateOf other: CacheCursor<Cursor, CacheStorage>) {
        self.init(cursor: other.cursor.clone(), storage: other.storage.clone())
    }
}

public extension CacheCursor {
    func copy() -> Self {
        return Self(cursor: cursor, storage: storage)
    }
}

public extension CacheCursor where Cursor: CloneableType {
    func shareCache() -> CacheCursor<Cursor, CacheStorage> {
        return CacheCursor(cursor: cursor.clone(), storage: storage)
    }
}

public extension CursorType where Self: PagePositionableType {
    func cached<CS: CacheStorageType>(in cacheStorage: CS) -> CacheCursor<Self, CS> {
        return CacheCursor(cursor: self, storage: cacheStorage)
    }
}

public extension CursorType where Self: PagePositionableType, Position.Page: Hashable {
    func cached() -> CacheCursor<Self, InMemoryCacheStorage<Position.Page, SuccessResult>> {
        return cached(in: InMemoryCacheStorageType())
    }
}

public extension CursorType where Self: PositionableType, Position: PageIndexableType, Position.Page: Hashable {
    typealias InMemoryCacheStorageType = InMemoryCacheStorage<Position.Page, SuccessResult>
}

public extension CursorType where Self: PagePositionableType, Position.Page: Hashable {
    typealias InMemoryCacheCursorType = CacheCursor<Self, Self.InMemoryCacheStorageType>
}
