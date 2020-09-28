public final class SimpleStubCursor<Page: PageType>: CursorType {
    public typealias Page = Page
    public typealias Failure = ExhaustedCursorError

    private let pages: [Page]

    private var currentPageIndex: Int

    private var exhausted: Bool {
        return currentPageIndex == pages.count
    }

    private init(pages: [Page], currentPageIndex: Int) {
        self.pages = pages
        self.currentPageIndex = currentPageIndex
    }

    public convenience init(pages: [Page]) {
        self.init(pages: pages, currentPageIndex: pages.startIndex)
    }

    public convenience init(singlePage: Page) {
        self.init(pages: [singlePage])
    }

    // MARK: - CursorType

    public func loadNextPage(completion: ResultCompletion) {
        guard !exhausted else {
            completion(.failure(.exhaustedError))
            return
        }

        let newItems = pages[currentPageIndex]

        currentPageIndex += 1
        completion(.success((page: newItems, exhausted: exhausted)))
    }
}

// MARK: - Conformances

extension SimpleStubCursor: ResettableType {
    public convenience init(withInitialStateFrom other: SimpleStubCursor<Page>) {
        self.init(pages: other.pages)
    }
}

extension SimpleStubCursor: CloneableType {
    public convenience init(keepingStateOf other: SimpleStubCursor<Page>) {
        self.init(pages: other.pages, currentPageIndex: other.currentPageIndex)
    }
}
