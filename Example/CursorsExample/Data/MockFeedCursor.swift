import Cursors
import Combine

public final class MockFeedCursor: CursorType {
    public enum FeedError: CursorErrorType {
        case exhausted
        case decodingFailed

        public var isExhausted: Bool {
            return self == .exhausted
        }

        public static var exhaustedError: FeedError {
            return .exhausted
        }
    }

    public typealias Element = Content
    public typealias Failure = FeedError

    fileprivate var currentPage = 1

    private var cancellable: Cancellable?

    public init(currentPage: Int = 1) {
        self.currentPage = currentPage
    }

    public func loadNextPage(completion: @escaping ResultCompletion) {
        cancellable?.cancel()

        let url = URL(string: "https://ce159633-eed1-407d-805e-6490f369ef36.mock.pstmn.io/feed/?page=\(currentPage)")!

        var request = URLRequest(url: url)
        request.setValue("064911a53f8e47b0a5c8eff084143bfb", forHTTPHeaderField: "x-api-token")

         let session = URLSession.shared

        cancellable = session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PaginatedFeed.self, decoder: JSONDecoder())
            .sink(receiveCompletion: {
                if case .failure = $0 {
                    completion(.failure(.decodingFailed))
                }
            }, receiveValue: { [weak self] in
                self?.handle(result: $0,
                             pageIncrement: 1,
                             completion: completion)
            })
    }

    private func handle(result: PaginatedFeed, pageIncrement: Int, completion: ResultCompletion) {
        currentPage += pageIncrement
        let exhausted = currentPage >= result.totalPages

        completion(.success((result.feed, exhausted)))
    }
}

extension MockFeedCursor: ResettableType {
    convenience public init(withInitialStateFrom other: MockFeedCursor) {
        self.init()
    }
}

extension MockFeedCursor: CloneableType {
    public convenience init(keepingStateOf other: MockFeedCursor) {
        self.init(currentPage: other.currentPage)
    }
}

