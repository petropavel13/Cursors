public protocol PageIndexableType {
    associatedtype Page

    var pageIndex: Page { get }
}
