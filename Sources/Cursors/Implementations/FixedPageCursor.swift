public final class FixedPageCursor<Cursor: CursorType>: CursorType {
    public typealias Element = Cursor.Element
    public typealias Failure = Cursor.Failure

    private final class Buffer: ClonableType {
        private var lastResult: Cursor.SuccessResult

        init(lastResult: Cursor.SuccessResult = (elements: [], exhausted: false)) {
            self.lastResult = lastResult
        }

        convenience init(keepingStateOf other: Buffer) {
            self.init(lastResult: other.lastResult)
        }

        func canDrain(pageSize: Int = 1) -> Bool {
            return lastResult.elements.count >= pageSize
        }

        func drain(pageSize: Int = .max) -> Result<Cursor.SuccessResult, Failure> {
            let numberOfItemsToDeliver = Swift.min(lastResult.elements.count, pageSize)

            let newItems = Array(lastResult.elements.prefix(upTo: numberOfItemsToDeliver))
            lastResult.elements.removeFirst(numberOfItemsToDeliver)

            guard !newItems.isEmpty else {
                return .failure(.exhausted)
            }

            return .success((elements: newItems, exhausted: lastResult.exhausted))
        }

        func fill(from result: Cursor.SuccessResult) {
            lastResult = (elements: lastResult.elements + result.elements, exhausted: result.exhausted)
        }
    }

    private let cursor: Cursor
    private let pageSize: Int

    private let buffer = Buffer()

    public init(cursor: Cursor, pageSize: Int) {
        self.cursor = cursor
        self.pageSize = pageSize
    }

    public func loadNextPage(completion: @escaping ResultCompletion) {
        if buffer.canDrain(pageSize: pageSize) {
            completion(buffer.drain(pageSize: pageSize))
        } else {
            cursor.loadNextPage {
                switch $0 {
                case let .success(result):
                    self.buffer.fill(from: result)

                    self.loadNextPage(completion: completion)
                case let .failure(failure):
                    if failure.isExhausted {
                        completion(self.buffer.drain())
                    } else {
                        completion($0)
                    }
                }
            }
        }
    }
}

// MARK: - Conditional conformances

extension FixedPageCursor: ResettableType where Cursor: ResettableType {
    public convenience init(withInitialStateFrom other: FixedPageCursor<Cursor>) {
        self.init(cursor: other.cursor.reset(), pageSize: other.pageSize)
    }
}

// MARK: - Operators

public extension CursorType {
    func paged(by pageSize: Int) -> FixedPageCursor<Self> {
        return FixedPageCursor(cursor: self, pageSize: pageSize)
    }
}
