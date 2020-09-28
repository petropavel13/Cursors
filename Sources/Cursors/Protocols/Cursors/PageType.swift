public protocol PageType {
    associatedtype Item

    var pageItems: [Item] { get }

    init(copy ancestor: Self, pageItems: [Item])
}
