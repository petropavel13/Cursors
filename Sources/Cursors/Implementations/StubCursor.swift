public final class StubCursor<Element>: BidirectionalCursorType {
    public typealias Pages = [[Element]]

    public typealias Element = Element
    public typealias Failure = ExhaustedCursorError

    public struct Position: Strideable {
        enum BoundaryPageAssignment {
            case left
            case right
        }

        public typealias Stride = Pages.Element.Index

        private let pages: Pages

        private let pageOffset: Pages.Index
        private let elementOffset: Pages.Element.Index

        private let index: Stride
        private let endIndex: Stride

        private init(pages: Pages,
                     pageOffset: Pages.Index,
                     elementOffset: Pages.Element.Index,
                     index: Stride,
                     endIndex: Stride) {

            self.pages = pages
            self.pageOffset = pageOffset
            self.elementOffset = elementOffset
            self.index = index
            self.endIndex = endIndex
        }

        init(pages: Pages,
             pageOffset: Pages.Index,
             elementOffset: Pages.Element.Index) {

            precondition(pages.indices.contains(pageOffset),
                         "pageOffset = \(pageOffset) is out of pages range \(pages.indices)!")
            precondition(pages[pageOffset].indices.contains(elementOffset),
                         "elementOffset = \(elementOffset) is out of pages[pageOffset] range \(pages[pageOffset].indices)!")

            let startIndexOnPage = pages.prefix(upTo: pageOffset)
                .reduce(0) { $0 + $1.count }

            let index = startIndexOnPage + elementOffset
            let endIndex = pages.suffix(from: pageOffset)
                .reduce(startIndexOnPage) { $0 + $1.count }

            self.init(pages: pages,
                      pageOffset: pageOffset,
                      elementOffset: elementOffset,
                      index: index,
                      endIndex: endIndex)
        }

        func move(to newIndex: Stride) -> Self {
            var currentIndex = 0

            var pageOffset = 0
            var elementOffset = 0

            for pageIndex in pages.indices {
                let page = pages[pageIndex]

                currentIndex += page.count

                if currentIndex >= newIndex {
                    pageOffset = pageIndex
                    if currentIndex == newIndex {
                        elementOffset = page.endIndex
                    } else if newIndex < index {
                        elementOffset = page.startIndex
                    } else {
                        elementOffset = page.index(before: currentIndex - newIndex)
                    }

                    break
                }
            }

            return Self(pages: pages,
                        pageOffset: pageOffset,
                        elementOffset: elementOffset,
                        index: newIndex,
                        endIndex: endIndex)
        }

        func move(by pagesCount: Pages.Index.Stride) -> Position {
            let newPageOffset = pageOffset.advanced(by: pagesCount)

            precondition(pages.indices.contains(newPageOffset),
                         "Can't move position by \(pagesCount). \(newPageOffset) is out of range")

            return Position(pages: pages,
                            pageOffset: newPageOffset,
                            elementOffset: pages[newPageOffset].startIndex)
        }

        var hasItemsBefore: Bool {
            return index > 0
        }

        var hasItemsAfter: Bool {
            return index < endIndex
        }

        var startItemsOnPage: Pages.Element.SubSequence {
            return pages[pageOffset].prefix(upTo: elementOffset)
        }

        var endItemsOnPage: Pages.Element.SubSequence {
            return pages[pageOffset].suffix(from: elementOffset)
        }

        var isBoundaryPosition: Bool {
            let page = pages[pageOffset]
            let isFirstBatch = pages.startIndex == pageOffset
            let isLastBatch = pages.index(before: pages.endIndex) == pageOffset
            return (page.startIndex == elementOffset && !isFirstBatch) || (page.endIndex == elementOffset && !isLastBatch)
        }

        public func distance(to other: Self) -> Stride {
            return index.distance(to: other.index)
        }

        public func advanced(by n: Stride) -> Self {
            guard n != 0 else {
                return self
            }

            return move(to: index.advanced(by: n))
        }

        func canMovePosition(to boundary: BoundaryPageAssignment) -> Bool {
            switch boundary {
            case .left:
                return pages[pageOffset].startIndex == elementOffset
            case .right:
                return pages[pageOffset].endIndex == elementOffset
            }
        }

        func movePosition(to boundary: BoundaryPageAssignment) -> Self {
            switch boundary {
            case .left:
                return Self(pages: pages,
                            pageOffset: pages.index(before: pageOffset),
                            elementOffset: pages[pageOffset].endIndex,
                            index: index,
                            endIndex: endIndex)
            case .right:
                return Self(pages: pages,
                            pageOffset: pages.index(after: pageOffset),
                            elementOffset: pages[pageOffset].startIndex,
                            index: index,
                            endIndex: endIndex)
            }
        }
    }

    fileprivate let pages: Pages
    fileprivate var currentPosition: Position

    public var initialPosition: Position {
        return Position(pages: pages, pageOffset: 0, elementOffset: 0)
    }

    private init(pages: Pages,
                 position: Position) {

        self.pages = pages
        self.currentPosition = position
    }

    public convenience init(pages: Pages,
                            elementOffset: Pages.SubSequence.Index = 0,
                            pageOffset: Pages.Index = 0) {

        let position = Position(pages: pages,
                                pageOffset: pageOffset,
                                elementOffset: elementOffset)

        self.init(pages: pages, position: position)
    }

    public convenience init(singlePage: Pages.Element) {
        self.init(pages: [singlePage])
    }

    public func loadNextPage(completion: ResultCompletion) {
        load(direction: .forward, completion: completion)
    }

    public func loadPreviousPage(completion: ResultCompletion) {
        load(direction: .backward, completion: completion)
    }

    private func load(direction: LoadDirection, completion: ResultCompletion) {
        let pageAssignment: Position.BoundaryPageAssignment = direction == .forward ? .right : .left

        if currentPosition.isBoundaryPosition && currentPosition.canMovePosition(to: pageAssignment) {
            currentPosition = currentPosition.movePosition(to: pageAssignment)
        }

        let hasNextItems = direction == .forward
            ? currentPosition.hasItemsAfter
            : currentPosition.hasItemsBefore

        guard hasNextItems else {
            completion(.failure(.exhaustedError))
            return
        }

        let newItems = direction == .forward
            ? currentPosition.endItemsOnPage
            : currentPosition.startItemsOnPage

        currentPosition = currentPosition.advanced(by: direction.normalize(newItems.count))

        let hasMoreItems = direction == .forward
            ? currentPosition.hasItemsAfter
            : currentPosition.hasItemsBefore

        completion(.success((elements: Array(newItems), exhausted: !hasMoreItems)))
    }
}

// MARK: - Conformances

extension StubCursor: ResettableType {
    public convenience init(withInitialStateFrom other: StubCursor<Element>) {
        self.init(pages: other.pages)
    }
}

extension StubCursor: ClonableType {
    public convenience init(keepingStateOf other: StubCursor<Element>) {
        self.init(pages: other.pages, position: other.currentPosition)
    }
}

extension StubCursor: SeekableType {
    public func seek(to position: Position) {
        currentPosition = position
    }
}

extension StubCursor: SkipableType {
    public func skip(pages: Int) {
        currentPosition = currentPosition.move(by: pages)
    }
}

// MARK: - Private helpers

private extension LoadDirection {
    func normalize<N: SignedNumeric>(_ stride: N) -> N {
        switch self {
        case .forward:
            return stride
        case .backward:
            var negativeStride = stride
            negativeStride.negate()
            return negativeStride
        }
    }
}
