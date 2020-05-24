public protocol PositionableType {
    associatedtype Position

    var movingForwardCurrentPosition: Position { get }

    func seek(to position: Position)
}
