public protocol PageIndexableType {
    associatedtype PageType

    var pageIndex: PageType { get }
}
