public protocol ElementIndexableType {
    associatedtype ElementIndex

    var elementIndex: ElementIndex { get }
}
