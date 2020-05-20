public final class StubCursor<Element>: BidirectionalCursorType {
    public typealias Pages = [[Element]]

    public typealias Element = Element
    public typealias Failure = ExhaustedCursorError

    public struct Position: PageIndexableType, ElementIndexableType, Strideable {
        enum BoundaryPageAssignment {
            case left
            case right
        }

        public typealias Stride = Pages.Element.Index

        private let pages: Pages

        public let pageIndex: Pages.Index
        public let elementIndex: Pages.Element.Index

        private let index: Stride
        private let endIndex: Stride

        private init(pages: Pages,
                     pageIndex: Pages.Index,
                     elementIndex: Pages.Element.Index,
                     index: Stride,
                     endIndex: Stride) {

            self.pages = pages
            self.pageIndex = pageIndex
            self.elementIndex = elementIndex
            self.index = index
            self.endIndex = endIndex
        }

        init(pages: Pages,
             pageIndex: Pages.Index,
             elementIndex: Pages.Element.Index) {

            if !pages.isEmpty {
                precondition(pages.indices.contains(pageIndex),
                             "pageIndex = \(pageIndex) is out of pages range \(pages.indices)!")
                precondition(pages[pageIndex].indices.contains(elementIndex),
                             "elementIndex = \(elementIndex) is out of pages[\(pageIndex)] range \(pages[pageIndex].indices)!")
            }

            let startIndexOnPage = pages.prefix(upTo: pageIndex)
                .reduce(0) { $0 + $1.count }

            let index = startIndexOnPage + elementIndex
            let endIndex = pages.suffix(from: pageIndex)
                .reduce(startIndexOnPage) { $0 + $1.count }

            self.init(pages: pages,
                      pageIndex: pageIndex,
                      elementIndex: elementIndex,
                      index: index,
                      endIndex: endIndex)
        }

        private func move(to newIndex: Stride) -> Self {
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
                    } else {
                        elementOffset = page.endIndex.advanced(by: newIndex - currentIndex)
                        currentIndex -= 1
                    }

                    break
                }
            }

            return Self(pages: pages,
                        pageIndex: pageOffset,
                        elementIndex: elementOffset,
                        index: newIndex,
                        endIndex: endIndex)
        }

        public func offset(pages pagesCount: Pages.Index.Stride) -> Position {
            let newpageIndex = pageIndex.advanced(by: pagesCount)

            precondition(pages.indices.contains(newpageIndex),
                         "Can't move position by \(pagesCount). \(newpageIndex) is out of range")

            return Position(pages: pages,
                            pageIndex: newpageIndex,
                            elementIndex: pages[newpageIndex].startIndex)
        }

        public func offset(elements elementsCount: Pages.Element.Index.Stride) -> Position {
            return move(to: index.advanced(by: elementsCount))
        }

        var hasItemsBefore: Bool {
            return index > 0
        }

        var hasItemsAfter: Bool {
            return index < endIndex
        }

        var startItemsOnPage: Pages.Element.SubSequence {
            return pages[pageIndex].prefix(upTo: elementIndex)
        }

        var endItemsOnPage: Pages.Element.SubSequence {
            return pages[pageIndex].suffix(from: elementIndex)
        }

        var isBoundaryPosition: Bool {
            let page = pages[pageIndex]
            let isFirstBatch = pages.startIndex == pageIndex
            let isLastBatch = pages.index(before: pages.endIndex) == pageIndex
            return (page.startIndex == elementIndex && !isFirstBatch) || (page.endIndex == elementIndex && !isLastBatch)
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
                return pages[pageIndex].startIndex == elementIndex
            case .right:
                return pages[pageIndex].endIndex == elementIndex
            }
        }

        func movePosition(to boundary: BoundaryPageAssignment) -> Self {
            switch boundary {
            case .left:
                return Self(pages: pages,
                            pageIndex: pages.index(before: pageIndex),
                            elementIndex: pages[pageIndex].endIndex,
                            index: index,
                            endIndex: endIndex)
            case .right:
                return Self(pages: pages,
                            pageIndex: pages.index(after: pageIndex),
                            elementIndex: pages[pageIndex].startIndex,
                            index: index,
                            endIndex: endIndex)
            }
        }
    }

    fileprivate let pages: Pages
    public private(set) var currentPosition: Position

    private init(pages: Pages,
                 position: Position) {

        self.pages = pages
        self.currentPosition = position
    }

    public convenience init(pages: Pages,
                            elementIndex: Pages.SubSequence.Index = 0,
                            pageIndex: Pages.Index = 0) {

        let position = Position(pages: pages,
                                pageIndex: pageIndex,
                                elementIndex: elementIndex)

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
        guard !pages.isEmpty else {
            completion(.failure(.exhaustedError))
            return
        }

        currentPosition = direction == .forward
            ? movingForwardCurrentPosition
            : movingBackwardCurrentPosition

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

extension StubCursor: BidirectionalPositionableType {
    public func seek(to newPosition: Position) {
        currentPosition = newPosition
    }

    public var movingForwardCurrentPosition: Position {
        guard currentPosition.isBoundaryPosition && currentPosition.canMovePosition(to: .right) else {
            return currentPosition
        }

        return currentPosition.movePosition(to: .right)
    }

    public var movingBackwardCurrentPosition: Position {
        guard currentPosition.isBoundaryPosition && currentPosition.canMovePosition(to: .left) else {
            return currentPosition
        }

        return currentPosition.movePosition(to: .left)
    }
}

extension StubCursor: ResettableType {
    public convenience init(withInitialStateFrom other: StubCursor<Element>) {
        self.init(pages: other.pages)
    }
}

extension StubCursor: CloneableType {
    public convenience init(keepingStateOf other: StubCursor<Element>) {
        self.init(pages: other.pages, position: other.currentPosition)
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
