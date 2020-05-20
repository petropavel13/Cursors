public protocol BidirectionalPositionableType: PositionableType {
    var movingForwardCurrentPosition: Position { get }

    var movingBackwardCurrentPosition: Position { get }
}

extension PositionableType {
    public var movingForwardCurrentPosition: Position {
        return currentPosition
    }

    public var movingBackwardCurrentPosition: Position {
        return currentPosition
    }
}
