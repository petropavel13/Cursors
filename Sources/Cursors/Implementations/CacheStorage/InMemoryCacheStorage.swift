public final class InMemoryCacheStorage<Page: Hashable, PageContent>: CacheStorageType {
    public typealias Page = Page
    public typealias PageContent = PageContent

    struct FetchRequest: Hashable {
        let page: Page
        let direction: LoadDirection
    }

    private var cachedPages: [FetchRequest: PageContent]

    public init() {
        cachedPages = [:]
    }

    public init(keepingStateOf other: InMemoryCacheStorage<Page, PageContent>) {
        cachedPages = other.cachedPages
    }

    public init(withInitialStateFrom other: InMemoryCacheStorage<Page, PageContent>) {
        cachedPages = [:]
    }

    public func loadPageContent(for request: Request, completion: @escaping ContentCompletionClosure) {
        completion(cachedPages[fetchRequest(for: request)])
    }

    public func save(pageContent: PageContent,
                     for request: Request,
                     completion: UpdateCacheCompletionClosure? = nil) {

        cachedPages[fetchRequest(for: request)] = pageContent
        completion?()
    }

    func fetchRequest(for request: Request) -> FetchRequest {
        return FetchRequest(page: request.page, direction: request.direction)
    }

    public func clear(completion: UpdateCacheCompletionClosure? = nil) {
        cachedPages.removeAll()
        completion?()
    }
}
