extension Array: PageType {
    public typealias Item = Element

    public init(copy ancestor: Array<Item>, pageItems: [Item]) {
        self.init(pageItems)
    }

    public var pageItems: [Item] {
        return self
    }
}
