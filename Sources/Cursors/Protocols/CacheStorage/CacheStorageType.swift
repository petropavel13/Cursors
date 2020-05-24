public protocol CacheStorageType: CloneableType, ResettableType {
    associatedtype Page
    associatedtype PageContent

    typealias ContentCompletionClosure = (PageContent?) -> Void
    typealias UpdateCacheCompletionClosure = () -> Void

    typealias Request = (page: Page, direction: LoadDirection)

    func loadPageContent(for request: Request,
                         completion: @escaping ContentCompletionClosure)

    func save(pageContent: PageContent,
              for request: Request,
              completion: UpdateCacheCompletionClosure?)

    func clear(completion: UpdateCacheCompletionClosure?)
}
