public protocol SeekableType {
    associatedtype Position

    var initialPosition: Position { get }

    func seek(to position: Position)
}
