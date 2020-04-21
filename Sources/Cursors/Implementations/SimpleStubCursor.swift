public final class SimpleStubCursor<Element>: CursorType {
    public typealias Element = Element
    public typealias Failure = ExhaustedCursorError

    private let pages: [[Element]]

    private var currentPageIndex: Int

    private var exhausted: Bool {
        return currentPageIndex == pages.count
    }

    private init(pages: [[Element]], currentPageIndex: Int) {
        self.pages = pages
        self.currentPageIndex = currentPageIndex
    }

    public convenience init(pages: [[Element]]) {
        self.init(pages: pages, currentPageIndex: pages.startIndex)
    }

    public convenience init(singlePage: [Element]) {
        self.init(pages: [singlePage])
    }

    public func loadNextPage(completion: ResultCompletion) {
        guard !exhausted else {
            completion(.failure(.exhaustedError))
            return
        }

        let newItems = pages[currentPageIndex]

        currentPageIndex += 1
        completion(.success((elements: newItems, exhausted: exhausted)))
    }
}

// MARK: - Conformances

extension SimpleStubCursor: ResettableType {
    public convenience init(withInitialStateFrom other: SimpleStubCursor<Element>) {
        self.init(pages: other.pages)
    }
}

extension SimpleStubCursor: SkipableType {
    public func skip(pages: Int) {
        currentPageIndex += pages
    }
}

extension SimpleStubCursor: CloneableType {
    public convenience init(keepingStateOf other: SimpleStubCursor<Element>) {
        self.init(pages: other.pages, currentPageIndex: other.currentPageIndex)
    }
}
