public protocol PositionableType {
    associatedtype Position

    var currentPosition: Position { get }

    func seek(to position: Position)
}
