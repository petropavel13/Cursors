public protocol ElementIndexableType {
    associatedtype ElementType

    var elementIndex: ElementType { get }
}
