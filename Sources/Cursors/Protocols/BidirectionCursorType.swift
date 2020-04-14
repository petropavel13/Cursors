public protocol BidirectionCursorType: CursorType {
    func loadPreviousPage(completion: @escaping ResultCompletion)
}
