public protocol PageIndexableType {
    associatedtype PageIndex

    var pageIndex: PageIndex { get }
}
