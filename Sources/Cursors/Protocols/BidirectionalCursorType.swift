public protocol BidirectionalCursorType: CursorType {
    func loadPreviousPage(completion: @escaping ResultCompletion)
}
